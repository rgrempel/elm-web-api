module WebAPI.WindowTest where

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)
import ElmTest.Runner.Element exposing (runDisplay)

import Task exposing (Task, andThen, sequence, map)
import Json.Decode as JD

import WebAPI.Window as Window


(>>>) = flip Task.map
(>>+) = Task.andThen


isOnline : Task x Test
isOnline =
    Window.isOnline >>> (assert >> test "isOnline should be true")
    

testValue : Task x Test
testValue =
    let
        mathPiDecoder =
            JD.at ["Math", "PI"] JD.float

    in
        Task.succeed <|
            test "Should be able to decode the window object" <|
                case JD.decodeValue mathPiDecoder Window.value of
                    Ok float ->
                        assertEqual Basics.pi float

                    Err _ ->
                        assert False


tests : Task () Test
tests =
    Task.map (suite "WebAPI.WindowTest") <|
        sequence
            [ isOnline
            , testValue
            ]
