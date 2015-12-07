module WebAPI.Event.CustomEventTest where

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)

import Task exposing (Task, andThen, sequence, map)
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE

import TestUtil exposing (sample)

import WebAPI.Window as Window
import WebAPI.Document as Document
import WebAPI.Event as Event
import WebAPI.Event.Custom as CustomEvent
import WebAPI.Date


and = flip Task.andThen
andAlways = and << always
recover = flip Task.onError


testListenerWithDetail : Task x Test
testListenerWithDetail =
    let
        mbox =
            Signal.mailbox (JE.int 0)

        responder event listener =
            [ Event.send (Signal.message mbox.address (CustomEvent.detail event))
            , Event.remove
            ]
    
    in
        CustomEvent.on "myownevent" responder Window.target
            |> andAlways (CustomEvent.construct "myownevent" (JE.int 17) Event.defaultOptions)
            |> and (CustomEvent.toEvent >> Event.dispatch Window.target)
            |> andAlways (Task.sleep 5) 
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual (Result.Ok 17) << JD.decodeValue JD.int)
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "listening with detail should work")


testToEvent : Task x Test
testToEvent =
    CustomEvent.construct "anevent" (JE.int 17) Event.defaultOptions
        |> Task.map (CustomEvent.toEvent >> Event.eventType)
        |> Task.map (assertEqual "anevent")
        |> Task.map (test "testToEvent")


testFromEventGood : Task x Test
testFromEventGood =
    CustomEvent.construct "anevent" (JE.int 17) Event.defaultOptions
        |> Task.map (CustomEvent.toEvent >> CustomEvent.fromEvent)
        |> Task.map (Maybe.map (CustomEvent.detail >> (JD.decodeValue JD.int)))
        |> Task.map (assertEqual (Just (Result.Ok 17)))
        |> Task.map (test "testFromEventGood")


testFromEventBad : Task x Test
testFromEventBad =
    Event.construct "anevent" Event.defaultOptions
        |> Task.map (CustomEvent.fromEvent)
        |> Task.map (assertEqual Nothing)
        |> Task.map (test "testFromEventBad")


testDecoderGood : Task x Test
testDecoderGood =
    CustomEvent.construct "myownevent" (JE.int 17) Event.defaultOptions
        |> Task.map (JD.decodeValue CustomEvent.decoder << CustomEvent.encode)
        |> Task.map (\result -> case result of
                Ok _ -> assert True
                Err _ -> assert False
            )
        |> Task.map (test "testDecoderGood")


testEventDecoder : Task x Test
testEventDecoder =
    CustomEvent.construct "myownevent" (JE.int 17) Event.defaultOptions
        |> Task.map (JD.decodeValue Event.decoder << CustomEvent.encode)
        |> Task.map (\result -> case result of
                Ok _ -> assert True
                Err _ -> assert False
            )
        |> Task.map (test "testEventDecoder")


testDecoderBad : Task x Test
testDecoderBad =
    Task.map (test "testDecoderBad") <|
        Task.succeed <|
            case JD.decodeValue CustomEvent.decoder JE.null of
                Ok _ -> assert False
                Err _ -> assert True


tests : Task () Test
tests =
    Task.map (suite "WebAPI.Event.CustomEventTest") <|
        sequence
            [ testListenerWithDetail
            , testToEvent
            , testFromEventGood, testFromEventBad
            , testDecoderGood, testEventDecoder, testDecoderBad
            ]
