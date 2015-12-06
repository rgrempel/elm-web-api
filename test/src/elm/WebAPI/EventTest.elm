module WebAPI.EventTest where

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)

import Task exposing (Task, andThen, sequence, map)
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE

import TestUtil exposing (sample)

import WebAPI.Window as Window
import WebAPI.Document as Document
import WebAPI.Event as Event
import WebAPI.Date


and = flip Task.andThen
andAlways = and << always
recover = flip Task.onError


mbox : Signal.Mailbox String
mbox = Signal.mailbox ""


testAddListener : Task x Test
testAddListener =
    let
        responder event listener =
            [ Event.send (Signal.message mbox.address "testBasicListener")
            , Event.remove
            ]
    
    in
        Event.addListener Event.Bubble "myownevent" responder Window.target
            |> andAlways (Event.construct "myownevent" Event.defaultOptions)
            |> and (Event.dispatch Window.target)
            |> andAlways (Task.sleep 5) 
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "testBasicListener")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "basic listening should work")


testAddListenerThenRemove : Task x Test
testAddListenerThenRemove =
    let
        mbox2 =
            Signal.mailbox 0

        count2 =
            Signal.foldp (\a state -> state + 1) 0 mbox2.signal

        responder event listener =
            [ Event.send (Signal.message mbox2.address 4) ]
    
        withListener listener =
            Event.construct "myownevent" Event.defaultOptions
                |> and (Event.dispatch Window.target)
                |> andAlways (Event.construct "myownevent" Event.defaultOptions)
                |> and (Event.dispatch Window.target)
                |> andAlways (Task.sleep 5)
                |> andAlways (Event.removeListener listener)
                |> andAlways (Event.construct "myownevent" Event.defaultOptions)
                |> and (Event.dispatch Window.target)

    in
        Event.addListener Event.Bubble "myownevent" responder Window.target
            |> and withListener
            |> andAlways (Task.sleep 5)
            |> andAlways (sample count2)
            |> Task.map (assertEqual 2)
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "should hear 2 but not 3")


testAddListenerOnce : Task x Test
testAddListenerOnce =
    let
        mbox3 =
            Signal.mailbox 0

        count3 =
            Signal.foldp (\a state -> state + 1) 0 mbox3.signal

        responder event listener =
            [ Event.send (Signal.message mbox3.address 0) ]
    
    in
        -- This is tricky to test, because addListenerOnce doesn't complete until the event
        -- occurs. So, we have to spawn it, but give it some time to set up the event handler
        -- before we test it.
        (Task.spawn (Event.addListenerOnce Event.Bubble "myownevent" responder Window.target))
            |> andAlways (Task.sleep 5)
            |> andAlways (Event.construct "myownevent" Event.defaultOptions)
            |> and (Event.dispatch Window.target)
            |> andAlways (Event.construct "myownevent" Event.defaultOptions)
            |> and (Event.dispatch Window.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample count3)
            |> Task.map (assertEqual 1)
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "addListenerOnce should listen once then stop")


testAddListenerOnceCompletesWithEvent : Task x Test
testAddListenerOnceCompletesWithEvent =
    let
        mbox4 =
            Signal.mailbox Nothing

        toSpawn =
            Event.addListenerOnce Event.Bubble "myownevent" Event.noResponse Window.target
                -- Should complete with the event ... send the event to the mailbox
                |> and (Signal.send mbox4.address << Just)

        checkEvent event =
            case event of
                Just ev ->
                    case JD.decodeValue Event.decoder ev of
                        Ok _ ->
                            assert True

                        Err _ ->
                            assert False
                
                Nothing ->
                    assert False

    in
        (Task.spawn toSpawn)
            |> andAlways (Task.sleep 5)
            |> andAlways (Event.construct "myownevent" Event.defaultOptions)
            |> and (Event.dispatch Window.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox4.signal)
            |> Task.map checkEvent
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "addListenerOnce should complete with the event")


testEventType : Task x Test
testEventType =
    Event.construct "anevent" Event.defaultOptions
        |> Task.map Event.eventType
        |> Task.map (assertEqual "anevent")
        |> Task.map (test "testEventType")


testDefaultOptions : Task x Test
testDefaultOptions =
    Event.construct "anevent" Event.defaultOptions
        |> Task.map (\event -> (Event.bubbles event, Event.cancelable event))
        |> Task.map (assertEqual (False, False))
        |> Task.map (test "testDefaultOptions")


testBubbles : Task x Test
testBubbles =
    Event.construct "anevent" { bubbles = True, cancelable = False }
        |> Task.map (\event -> (Event.bubbles event, Event.cancelable event))
        |> Task.map (assertEqual (True, False))
        |> Task.map (test "testBubbles")


testCancelable : Task x Test
testCancelable =
    Event.construct "anevent" { bubbles = False, cancelable = True }
        |> Task.map (\event -> (Event.bubbles event, Event.cancelable event))
        |> Task.map (assertEqual (False, True))
        |> Task.map (test "testCancelable")


testTimestamp : Task x Test
testTimestamp =
    let
        eventTask =
            Event.construct "anevent" Event.defaultOptions

        timeTask =
            WebAPI.Date.now

    in
        Task.map2 (\event time ->
            assert (time - (Event.timestamp event) < 100)
                |> test "testTimestamp"
        ) eventTask timeTask


testPhaseNone : Task x Test
testPhaseNone =
    Event.construct "anevent" Event.defaultOptions
        |> Task.map Event.eventPhase
        -- Note that most browsers give NoPhase for an undispatched event, but
        -- Opera gives AtTarget
        |> Task.map (\phase -> assert (phase == Event.NoPhase || phase == Event.AtTarget))
        |> Task.map (test "testPhaseNone")


testPhaseCapturing : Task x Test
testPhaseCapturing =
    let
        responder event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address <|
                    "capturing " ++ (toString (Event.eventPhase event))
            ]

    in
        Event.addListener Event.Capture "myownevent" responder Window.target
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = False})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "capturing Capturing")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testPhaseCapturing")


testPhaseAtTarget : Task x Test
testPhaseAtTarget =
    let
        responder event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address <|
                    "atTarget " ++ (toString (Event.eventPhase event))
            ]

    in
        Event.addListener Event.Capture "myownevent" responder Document.target
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = False})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "atTarget AtTarget")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testPhaseAtTarget")


testPhaseBubbling : Task x Test
testPhaseBubbling =
    let
        responder event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address <|
                    "bubbling " ++ (toString (Event.eventPhase event))
            ]

    in
        Event.addListener Event.Bubble "myownevent" responder Window.target
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = False})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "bubbling Bubbling")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testPhaseBubbling")


testDefaultPreventedFresh : Task x Test
testDefaultPreventedFresh =
    Event.construct "anevent" { bubbles = False, cancelable = True }
        |> Task.map Event.defaultPrevented
        |> Task.map (assertEqual False)
        |> Task.map (test "testDefaultPreventedFresh")


testDefaultPreventedTrue : Task x Test
testDefaultPreventedTrue =
    let
        responder1 event listener =
            [ Event.remove
            , Event.preventDefault event
            ]

        responder2 event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address <|
                    "defaultPreventedTrue " ++ (toString (Event.defaultPrevented event))
            ]

    in
        Event.addListener Event.Bubble "myownevent" responder1 Document.target
            |> andAlways (Event.addListener Event.Bubble "myownevent" responder2 Window.target)
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = True})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "defaultPreventedTrue True")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testDefaulPreventedTrue")


testDefaultPreventedFalse : Task x Test
testDefaultPreventedFalse =
    let
        responder1 event listener =
            [ Event.remove
            ]

        responder2 event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address <|
                    "defaultPreventedFalse " ++ (toString (Event.defaultPrevented event))
            ]

    in
        Event.addListener Event.Bubble "myownevent" responder1 Document.target
            |> andAlways (Event.addListener Event.Bubble "myownevent" responder2 Window.target)
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = True})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "defaultPreventedFalse False")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testDefaultPreventedFalse")


testEventTargetNothing : Task x Test
testEventTargetNothing =
    Event.construct "anevent" Event.defaultOptions
        |> Task.map Event.eventTarget
        |> Task.map (\target -> assert (target == Nothing))
        |> Task.map (test "testEventTargetNothing")


testEventTarget : Task x Test
testEventTarget =
    let
        responder event listener =
            let
                wasDocumentTarget =
                    Event.eventTarget event == Just Document.target

            in
                [ Event.remove
                , Event.send <|
                    Signal.message mbox.address <|
                        "testEventTargetDispatched " ++ (toString wasDocumentTarget)
                ]

    in
        Event.addListener Event.Bubble "myownevent" responder Window.target
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = True})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "testEventTargetDispatched True")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testEventTarget")


testListenerTarget : Task x Test
testListenerTarget =
    let
        responder event listener =
            let
                wasWindowTarget =
                    Event.listenerTarget event == Just Window.target

            in
                [ Event.remove
                , Event.send <|
                    Signal.message mbox.address <|
                        "testListenerTargetDispatched " ++ (toString wasWindowTarget)
                ]

    in
        Event.addListener Event.Bubble "myownevent" responder Window.target
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = True})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "testListenerTargetDispatched True")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testListenerTarget")


testDispatchReturnTrue : Task x Test
testDispatchReturnTrue =
    let
        responder event listener =
            [ Event.remove
            ]
    
    in
        Event.addListener Event.Bubble "myownevent" responder Window.target
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = True})
            |> and (Event.dispatch Window.target)
            |> Task.map assert
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testDispatchReturnTrue")


testDispatchReturnFalse : Task x Test
testDispatchReturnFalse =
    let
        responder event listener =
            [ Event.remove
            , Event.preventDefault event
            ]
    
    in
        Event.addListener Event.Bubble "myownevent" responder Window.target
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = True})
            |> and (Event.dispatch Window.target)
            |> Task.map (assert << not)
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testDispatchReturnFalse")


testListenerType : Task x Test
testListenerType =
    let
        withListener listener =
            Event.removeListener listener
                |> Task.map (always (assertEqual "myevent" (Event.listenerType listener)))

    in
        Event.addListener Event.Bubble "myevent" Event.noResponse Window.target
            |> and withListener
            |> Task.map (test "testListenerType")


testListenerTypeInResponder : Task x Test
testListenerTypeInResponder =
    let
        responder event listener =
            [ Event.send (Signal.message mbox.address ("testListenerTypeInResponder " ++ (Event.listenerType listener)))
            , Event.remove
            ]
    
    in
        Event.addListener Event.Bubble "someevent" responder Window.target
            |> andAlways (Event.construct "someevent" Event.defaultOptions)
            |> and (Event.dispatch Window.target)
            |> andAlways (Task.sleep 5) 
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "testListenerTypeInResponder someevent")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "the listener should be a param to the responder")


testPhase : Task x Test
testPhase =
    let
        withListener listener =
            Event.removeListener listener
                |> Task.map (always (assertEqual Event.Bubble (Event.listenerPhase listener)))

    in
        Event.addListener Event.Bubble "myevent" Event.noResponse Window.target
            |> and withListener
            |> Task.map (test "testTarget")


testSet : Task x Test
testSet =
    let
        responder1 event listener =
            [ Event.remove
            , Event.set "testKey" (JE.string "testValue")
            ]

        responder2 event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address <|
                    case JD.decodeValue ("testKey" := JD.string) (Event.encode event) of
                        Ok string ->
                            "testSet " ++ string

                        Err _ ->
                            "testSet erred"
            ]

    in
        Event.addListener Event.Bubble "myownevent" responder1 Document.target
            |> andAlways (Event.addListener Event.Bubble "myownevent" responder2 Window.target)
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = True})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "testSet testValue")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testSet")


testStopPropagation : Task x Test
testStopPropagation =
    let
        responder1 event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address "testStopPropagation stage1"
            , Event.stopPropagation event
            ]

        responder2 event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address "testStopPropagation stage2"
            ]

    in
        Event.addListener Event.Bubble "myownevent" responder1 Document.target
            |> andAlways (Event.addListener Event.Bubble "myownevent" responder2 Window.target)
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = True})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "testStopPropagation stage1")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testStopPropagation")


testStopImmediatePropagation : Task x Test
testStopImmediatePropagation =
    let
        responder1 event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address "testStopImmediatePropagation stage1"
            , Event.stopImmediatePropagation event
            ]

        responder2 event listener =
            [ Event.remove
            , Event.send <|
                Signal.message mbox.address "testStopImmediatePropagation stage2"
            ]

    in
        Event.addListener Event.Bubble "myownevent" responder1 Document.target
            |> andAlways (Event.addListener Event.Bubble "myownevent" responder2 Document.target)
            |> andAlways (Event.construct "myownevent" {bubbles = True, cancelable = True})
            |> and (Event.dispatch Document.target)
            |> andAlways (Task.sleep 5)
            |> andAlways (sample mbox.signal)
            |> Task.map (assertEqual "testStopImmediatePropagation stage1")
            |> recover (Task.succeed << assertEqual "no error")
            |> Task.map (test "testStopImmediatePropagation")


testDecoderGood : Task x Test
testDecoderGood =
    Event.construct "myownevent" {bubbles = True, cancelable = True}
        |> Task.map (JD.decodeValue Event.decoder << Event.encode)
        |> Task.map (\result -> case result of
                Ok _ -> assert True
                Err _ -> assert False
            )
        |> Task.map (test "testDecoderGood")


testDecoderBad : Task x Test
testDecoderBad =
    Task.map (test "testDecoderBad") <|
        Task.succeed <|
            case JD.decodeValue Event.decoder JE.null of
                Ok _ -> assert False
                Err _ -> assert True


tests : Task () Test
tests =
    Task.map (suite "WebAPI.EventTest") <|
        sequence
            [ testAddListener, testAddListenerThenRemove
            , testAddListenerOnce, testAddListenerOnceCompletesWithEvent 
            , testEventType
            , testDefaultOptions, testBubbles, testCancelable
            , testTimestamp
            , testPhaseNone, testPhaseCapturing, testPhaseAtTarget, testPhaseBubbling
            , testDefaultPreventedFresh, testDefaultPreventedTrue, testDefaultPreventedFalse
            , testEventTargetNothing, testEventTarget, testListenerTarget
            , testDispatchReturnTrue, testDispatchReturnFalse
            , testListenerType, testListenerTypeInResponder
            , testPhase
            , testSet
            , testStopPropagation, testStopImmediatePropagation
            , testDecoderGood, testDecoderBad
            ]
