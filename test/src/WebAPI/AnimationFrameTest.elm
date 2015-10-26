module WebAPI.AnimationFrameTest where

import ElmTest.Test exposing (..)
import ElmTest.Assertion exposing (..)
import Task exposing (Task, sequence, succeed, andThen)
import Time exposing (Time)
import String

import TestMailbox

import WebAPI.AnimationFrame as AnimationFrame
import WebAPI.Date
import Debug


-- We'll allow up to 1/40 of a second for the test
frame : Time
frame = Time.second / 40


taskTest : Task () Test
taskTest =
    WebAPI.Date.now `andThen` (\startTime ->
    AnimationFrame.task `andThen` (\timestamp ->
    AnimationFrame.task `andThen` (\timestamp2 ->
    WebAPI.Date.now `andThen` (\endTime ->
        let
            wallTime =
                endTime - startTime

            delta =
                timestamp2 - timestamp

        in
            Task.succeed <|
                suite "task"
                    [ test "wall time not too long" <|
                        assert (wallTime < frame * 2)
                    , test "callback time seems sane" <|
                        assert (delta < frame)
                    ]
    ))))


requestTest : Task () Test
requestTest =
    let
        task time =
            Signal.send
                (.address TestMailbox.tests) <|
                    test "AnimationFrame.request" <|
                        assert (time > 0)
            
    in
        AnimationFrame.request task
            |> Task.map (always (suite "Deferred" []))


cancelTest : Task () Test
cancelTest =
    let
        task time =
            Signal.send
                (.address TestMailbox.tests) <|
                    test "AnimationFrame.cancel" <|
                        -- The idea is that this should never actualy be sent,
                        -- because we're going to cancel it. So, if it is
                        -- sent, we want to fail.
                        assert False

    in
        AnimationFrame.request task `Task.andThen` (\request ->
            AnimationFrame.cancel request
        ) |> Task.map (always (suite "Deferred" []))
 

tests : Task () Test
tests =
    Task.map (suite "WebAPI.AnimationFrameTest") <|
        sequence <|
            [ taskTest
            , requestTest
            , cancelTest
            ]

