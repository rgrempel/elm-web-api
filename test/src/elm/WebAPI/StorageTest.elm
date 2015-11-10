module WebAPI.StorageTest where

import ElmTest.Test exposing (..)
import ElmTest.Assertion exposing (..)
import Task exposing (Task, sequence, succeed, andThen)

import WebAPI.Storage exposing (..)


(>>>) = flip Task.map
(>>+) = Task.andThen
(>>!) = Task.onError


(>>-) task func =
    task `andThen` (always func)


reportError : Bool -> String -> Error -> Task x Test
reportError disabled name error =
    Task.succeed <|
        test (name ++ ": " ++ (toString error)) <|
            -- If we're disabled, then we expected an error ...
            -- so, that's good. If not, then we didn't.
            if disabled
                then assertEqual error Disabled
                else assert False


length0Test : Bool -> Storage -> Task x Test
length0Test disabled storage =
    clear storage
    >>- length storage
    >>> (assertEqual 0 >> test "length0")
    >>! reportError disabled "length0"


length1Test : Bool -> Storage -> Task x Test
length1Test disabled storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- length storage
    >>> (assertEqual 1 >> test "length1")
    >>! reportError disabled "length1"


keyTestSuccess : Bool -> Storage -> Task x Test
keyTestSuccess disabled storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- key storage 0
    >>> (assertEqual (Just "bob") >> test "keySuccess")
    >>! reportError disabled "keySuccess"


keyTestError : Bool -> Storage -> Task x Test
keyTestError disabled storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- key storage 5
    >>> (assertEqual Nothing >> test "keyError")
    >>! reportError disabled "keyError"


getItemTestSuccess : Bool -> Storage -> Task x Test
getItemTestSuccess disabled storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- get storage "bob"
    >>> (assertEqual (Just "joe") >> test "getItemSuccess")
    >>! reportError disabled "getItemSuccess"


getItemTestError : Bool -> Storage -> Task x Test
getItemTestError disabled storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- get storage "wrong"
    >>> (assertEqual Nothing >> test "getItemError")
    >>! reportError disabled "getItemError"


removeItemTest : Bool -> Storage -> Task x Test
removeItemTest disabled storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- remove storage "bob"
    >>- length storage
    >>> (assertEqual 0 >> test "removeItem")
    >>! reportError disabled "removeItem"


removeItemTestError : Bool -> Storage -> Task x Test
removeItemTestError disabled storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- remove storage "not there"
    >>- length storage
    >>> (assertEqual 1 >> test "removeItemError")
    >>! reportError disabled "removeItemError"


enabledTest : Bool -> Task x Test
enabledTest disabled =
    enabled
    >>> (assertEqual (not disabled) >> test "Enabled")


tests : Bool -> Task x Test
tests disabled =
    Task.map (suite "Storage") <|
        sequence <|
            List.map (makeSuite disabled)
                [ (local, "localStorage")
                , (session, "sessionStorage")
                ]
            ++
            [ enabledTest disabled ]


makeSuite : Bool -> (Storage, String) -> Task x Test
makeSuite disabled (storage, label) =
    Task.map (suite label) <|
        sequence
            [ length0Test disabled storage
            , length1Test disabled storage
            , keyTestSuccess disabled storage
            , keyTestError disabled storage
            , getItemTestSuccess disabled storage
            , getItemTestError disabled storage
            , removeItemTest disabled storage
            , removeItemTestError disabled storage
            ]
