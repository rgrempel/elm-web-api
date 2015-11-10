module WebAPI.Event
    ( Target, addListener, on, removeListener, addListenerOnce, once
    , Responder, Phase(Capture, Bubble)
    , Response, preventDefault, stopPropagation, stopImmediatePropagation, set, send, performTask, remove
    , Listener, eventName, responder, target, phase
    ) where

{-| General support for handling Javascript events.

This is a low-level module ...  normally, you will want to use more specific
methods in other modules -- assuming that they do what you want :-)

Furthermore, this is not really meant for targets that are within the `Html`
that your `view` function produces. For those, use `Html.Events` to deal with
events. Instead, this is meant for events on target that you don't set up in
your `view` function, such as the `window` and `document` etc.

See Mozilla documentation for the
[`EventTarget` interface](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget).
I also found this
[list of events](http://www.w3schools.com/jsref/dom_obj_event.asp)
helpful.

## Handling Events

@docs Target, addListener, on, Phase, addListenerOnce, once

## Constructing Responses

@docs Responder
@docs Response, preventDefault, stopPropagation, stopImmediatePropagation, set, send, performTask, remove

## Listeners

@docs Listener, removeListener
@docs eventName, responder, target, phase
-}


import Task exposing (Task)
import Json.Decode
import Json.Encode

import Native.WebAPI.Event


{- ---------------
   Handling Events
   --------------- -}

{-| Opaque type which represents a Javascript object which can respond to
Javascript's `addEventListener()` and `removeEventListener()`.

To obtain a `Target`, see methods such as `WebAPI.Document.events` and
`WebAPI.Window.events`.
-}
type Target = Target


{-| A task which, when executed, uses Javascript's `addEventListener()` to add
a `Responder` to the `Target` for the event specified by the string (e.g. "click").

Succeeds with a `Listener`, which you can supply to `removeListener` if you
wish.
-}
addListener : Phase -> String -> Responder a b -> Target -> Task x Listener
addListener = Native.WebAPI.Event.addListener


{-| Convenience method for the usual case in which you call `addListener`
for the `Bubble` phase.
-}
on : String -> Responder a b -> Target -> Task x Listener
on = addListener Bubble


{-| Like `addListener`, but only responds to the event once, and the resulting
`Task` only succeeds when the event occurs (with the value of the event object).
Thus, your `Responder` method might not need to do anything.
-}
addListenerOnce : Phase -> String -> Responder a b -> Target -> Task x Json.Decode.Value
addListenerOnce = Native.WebAPI.Event.addListenerOnce


{-| Like `addListenerOnce`, but supplies the default `Phase` (`Bubble`), and a
`Responder` that does nothing (so you merely chain the resulting `Task`).
-}
once : String -> Target -> Task x Json.Decode.Value
once string target =
    let
        doNothing value listener =
            []

    in
        addListenerOnce Bubble string doNothing target


{-| A task which will remove the supplied `Listener`.

Alternatively, you can return `remove` from your `Responder` method, and the
listener will be removed.
-}
removeListener : Listener -> Task x ()
removeListener = Native.WebAPI.Event.removeListener


{-| The phase in which a `Responder` will be invoked. Typically, you will want `Bubble`. -}
type Phase
    = Capture
    | Bubble


{- ----------------------
   Constructing Responses
   ---------------------- -}

{-| A function which will be called each time an event occurs, in order to
determine how to respond to the event.

* The `Json.Decode.Value` is the Javascript event object, which you might want
to analyze further via a `Json.Decode.Decoder`.  There are decoders defined in
the `Html.Events` module of
[evancz/elm-html](http://package.elm-lang.org/packages/evancz/elm-html/latest)
that you may find helpful for this.

* The `Listener` is the listener which is responsible for this event.

Your function should return a list of responses which you would like to make
to the event.
-}
type alias Responder x a =
    Json.Decode.Value -> Listener -> List (Response x a)


{-| Represents a response which you would like to make to an event. -}
type Response x a
    = PreventDefault
    | StopPropagation
    | StopImmediatePropagation
    | Remove
    | Set String Json.Encode.Value
    | Send Signal.Message
    | PerformTask (Task x a)


{-| Indicates that you would like to call `preventDefault()` on the event object. -}
preventDefault : Response x a
preventDefault = PreventDefault


{-| Indicates that you would like to call `stopPropagation()` on the event object. -}
stopPropagation : Response x a
stopPropagation = StopPropagation


{-| Indicates that you would like to call `stopImmediatePropagation()` on the event object. -}
stopImmediatePropagation : Response x a
stopImmediatePropagation = StopImmediatePropagation


{-| Indicates that you would like to set a property on the event object with
the specified key to the specified value.

Normally, you should not need this. However, there are some events which need
to be manipulated in this way -- for instance, setting the `returnValue` on the
`beforeunload` event.
-}
set : String -> Json.Encode.Value -> Response x a
set = Set


{-| Indicates that you would like to send a message in response to the event. -}
send : Signal.Message -> Response x a
send = Send


{-| Indicates that you would like to perform a `Task` in response to the event.

If the task is to send a message via `Signal.send`, then you can use `send` as
a convenience.
-}
performTask : Task x a -> Response x a
performTask = PerformTask


{-| Indicates that no longer wish to listen for this event on this target. -}
remove : Response x a
remove = Remove


{- ---------
   Listeners
   --------- -}

{-| Opaque type representing an event handler. -}
type Listener a b = Listener
    -- We don't expose the record type directly, because we don't want people
    -- to be able to construct one manually -- it needs to be the right type
    -- in the native code, so we have to construct it for you.
    { eventName : String
    , responder : Responder a b
    , target : Target
    , phase : Phase
    }


{-| The name of the listener's event. -}
eventName : Listener a b -> String
eventName (Listener listener) = listener.eventName


{-| The responder used by the listener. -}
responder : Listener a b -> Responder a b
responder (Listener listener) = listener.responder


{-| The listener's target. -}
target : Listener a b -> Target
target (Listener listener) = listener.target


{-| The listener's phase. -}
phase : Listener a b -> Phase
phase (Listener listener) = listener.phase
