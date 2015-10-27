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


-- When testing on SauceLabs, this is really slow ... much faster locally ...
-- not sure why. So, we allow an absurd amount of time for a frame here ...
-- when run locally, the frame rate is about right
frame : Time
frame = Time.second / 5


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
                    [ test
                        ( String.join " "
                            [ "wall time"
                            , toString wallTime
                            , "is less than"
                            , toString (frame * 2)
                            ]
                        ) <|
                        assert (wallTime < frame * 2)
                    , test
                        ( String.join " "
                            [ "callback time"
                            , toString delta 
                            , "is less than"
                            , toString frame
                            ]
                        ) <|
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

