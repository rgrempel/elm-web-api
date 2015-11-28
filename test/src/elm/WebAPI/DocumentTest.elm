module WebAPI.DocumentTest where

import String
import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)

import Task exposing (Task, andThen, sequence, map)
import TestUtil exposing (sample)
import Signal.Extra exposing (foldp')
import Json.Decode as JD
import Time

import WebAPI.Document exposing (..)


(>>>) = flip Task.map
(>>+) = Task.andThen


(>>-) task func =
    task `andThen` (always func)


getReadyStateTest : Task x Test
getReadyStateTest =
    getReadyState >>> (\state ->
        test ("getReadyState got " ++ (toString state)) <| 
            -- Basically, this succeeds if it doesn't throw an error
            assert <|
                state == Loading ||
                state == Interactive ||
                state == Complete
    )


readyStateTest : Task x Test
readyStateTest =
    let
        accumulator =
            foldp'  (::) (\s -> [s]) readyState

    in
        Task.sleep (0.5 * Time.second) >>-
        sample accumulator >>> (\list ->
            test ("readyState signal: " ++ (toString list)) <|
                assert <|
                    List.length list >= 2
        )


getTitleTest : Task x Test
getTitleTest =
    getTitle >>> (\title ->
        test "getTitle should be 'Main'" <|
            assertEqual "Main" title
    )


setTitleTest : Task x Test
setTitleTest =
    setTitle "New title" >>+ (\setTitleResponse ->
        getTitle >>> (\newTitle ->
            test "setTitle should work" <|
                assert <|
                    setTitleResponse == () &&
                    newTitle == "New title"
        )
    )


testValue : Task x Test
testValue =
    let
        titleDecoder =
            JD.at ["title"] JD.string

    in
        Task.succeed <|
            test "Should be able to decode the document object" <|
                case JD.decodeValue titleDecoder value of
                    Ok string ->
                        assertEqual "Main" string

                    Err _ ->
                        assert False


tests : Task () Test
tests =
    Task.map (suite "WebAPI.DocumentTest") <|
        sequence
            [ getReadyStateTest
            , readyStateTest
            , testValue
            , getTitleTest, setTitleTest
            ]
