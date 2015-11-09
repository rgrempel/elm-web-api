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


reportError : String -> Error -> Task x Test
reportError name error =
    Task.succeed <|
        test (name ++ ": " ++ (toString error)) <|
            assert False


length0Test : Storage -> Task x Test
length0Test storage =
    clear storage
    >>- length storage
    >>> (assertEqual 0 >> test "length0")
    >>! reportError "length0"


length1Test : Storage -> Task x Test
length1Test storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- length storage
    >>> (assertEqual 1 >> test "length1")
    >>! reportError "length1"


keyTestSuccess : Storage -> Task x Test
keyTestSuccess storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- key storage 0
    >>> (assertEqual (Just "bob") >> test "keySuccess")
    >>! reportError "keySuccess"


keyTestError : Storage -> Task x Test
keyTestError storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- key storage 5
    >>> (assertEqual Nothing >> test "keyError")
    >>! reportError "keyError"


getItemTestSuccess : Storage -> Task x Test
getItemTestSuccess storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- get storage "bob"
    >>> (assertEqual (Just "joe") >> test "getItemSuccess")
    >>! reportError "getItemSuccess"


getItemTestError : Storage -> Task x Test
getItemTestError storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- get storage "wrong"
    >>> (assertEqual Nothing >> test "getItemError")
    >>! reportError "getItemError"


removeItemTest : Storage -> Task x Test
removeItemTest storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- remove storage "bob"
    >>- length storage
    >>> (assertEqual 0 >> test "removeItem")
    >>! reportError "removeItem"


removeItemTestError : Storage -> Task x Test
removeItemTestError storage =
    clear storage
    >>- set storage "bob" "joe"
    >>- remove storage "not there"
    >>- length storage
    >>> (assertEqual 1 >> test "removeItemError")
    >>! reportError "removeItemError"


enabledTest : Task x Test
enabledTest =
    enabled
    >>> (assert >> test "Enabled")


tests : Task x Test
tests =
    Task.map (suite "Storage") <|
        sequence <|
            List.map makeSuite
                [ (local, "localStorage")
                , (session, "sessionStorage")
                ]
            ++
            [ enabledTest ]


makeSuite : (Storage, String) -> Task x Test
makeSuite (storage, label) =
    Task.map (suite label) <|
        sequence
            [ length0Test storage
            , length1Test storage
            , keyTestSuccess storage
            , keyTestError storage
            , getItemTestSuccess storage
            , getItemTestError storage
            , removeItemTest storage
            , removeItemTestError storage
            ]
