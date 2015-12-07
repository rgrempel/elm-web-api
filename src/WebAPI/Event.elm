module WebAPI.Event
    ( Event, eventType, bubbles, cancelable, timestamp
    , EventPhase(NoPhase, Capturing, AtTarget, Bubbling), eventPhase
    , defaultPrevented, eventTarget, listenerTarget
    , Options, defaultOptions, construct, dispatch
    , Target, addListener, on, addListenerOnce, once
    , Listener, listenerType, responder, target, removeListener
    , ListenerPhase(Capture, Bubble), listenerPhase
    , Responder, noResponse
    , Response, preventDefault, stopPropagation, stopImmediatePropagation, set, send, performTask, remove
    , encode, decoder
    ) where

{-| Support for Javascript events.

There are more specific modules available for more specific types of events --
for instance, `WebAPI.Event.BeforeUnload` for the `BeforeUnloadEvent`. So, if
you're interested in a specific type of event, check there first.

Also, there are specific modules available for some targets. For instance,
`WebAPI.Window` has some convenient event-handling methods.

Furthermore, if you are using
[evancz/elm-html](http://package.elm-lang.org/packages/evancz/elm-html/latest),
this is not really meant for targets that are within the `Html` that your
`view` function produces. For those, use `Html.Events` to deal with events.
Instead, this is meant for events on target that you don't set up in your
`view` function, such as the `window` and `document` etc. Though, of course,
you could possibly achieve some interesting results by setting up listeners on
the document or window and relying on bubbling.

See Mozilla documentation for the
[`EventTarget` interface](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget),
and for [`Event`](https://developer.mozilla.org/en-US/docs/Web/API/Event).
I also found this
[list of events](http://www.w3schools.com/jsref/dom_obj_event.asp)
helpful.

## Events

@docs Event, eventType, bubbles, cancelable, timestamp
@docs EventPhase, eventPhase
@docs defaultPrevented, eventTarget, listenerTarget

## Constructing and Dispatching

@docs construct, Options, defaultOptions, dispatch

## Listening

@docs Target, addListener, on, addListenerOnce, once
@docs Listener, listenerType, responder, target, ListenerPhase, listenerPhase, removeListener

## Responding

@docs Responder
@docs Response, set, send, performTask, remove
@docs stopPropagation, stopImmediatePropagation, preventDefault
@docs noResponse

## JSON

@docs encode, decoder
-}


import Task exposing (Task)
import Time exposing (Time)
import Json.Decode
import Json.Encode

import WebAPI.Native
import Native.WebAPI.Listener
import Native.WebAPI.Event


{- -----
   Event
   ----- -}


{-| Opaque type representing a Javascript event. -}
type Event = Event


{-| The type of the event. -}
eventType : Event -> String
eventType = Native.WebAPI.Event.eventType


{-| Does the event bubble up through the DOM? -}
bubbles : Event -> Bool
bubbles = Native.WebAPI.Event.bubbles


{-| Can the event be canceled? -}
cancelable : Event -> Bool
cancelable = Native.WebAPI.Event.cancelable


{-| The time when the event was created. -}
timestamp : Event -> Time
timestamp = Native.WebAPI.Event.timestamp


{-| The phases in which an event can be processed. -}
type EventPhase
    = NoPhase      -- 0
    | Capturing    -- 1
    | AtTarget     -- 2
    | Bubbling     -- 3


nativeEventPhase : Event -> Int
nativeEventPhase = Native.WebAPI.Event.eventPhase


toEventPhase : Int -> EventPhase
toEventPhase int =
    case int of
        0 -> NoPhase
        1 -> Capturing
        2 -> AtTarget
        3 -> Bubbling
        _ -> Debug.crash ("Unexpected value for nativeEventPhase: " ++ (toString int))


{-| The phase in which the event is currently being processed.

Note that typically an undispatched `Event` will return `NoPhase`, but in
Opera will return `AtTarget`.
-}
eventPhase : Event -> EventPhase
eventPhase = toEventPhase << nativeEventPhase


{-| Has `preventDefault()` been called on this event? -}
defaultPrevented : Event -> Bool
defaultPrevented = Native.WebAPI.Event.defaultPrevented


{-| The target that the event was originally dispatched to. -}
eventTarget : Event -> Maybe Target
eventTarget = Native.WebAPI.Event.target


{-| The target that the current event listener was attached to. This may differ
from the target which originally received the event, if we are in the bubbling
or capturing phase.
-}
listenerTarget : Event -> Maybe Target
listenerTarget = Native.WebAPI.Event.currentTarget


{- ----------------------------
   Constructing and Dispatching
   ---------------------------- -}


{-| Create an event with the given eventType and options. -}
construct : String -> Options -> Task x Event
construct = Native.WebAPI.Event.event


{-| Options for creating events. -}
type alias Options =
    { cancelable : Bool
    , bubbles : Bool
    }


{-| Default options, in which both are false. -}
defaultOptions : Options
defaultOptions = Options False False


{-| A task which dispatches an event, and completes when all the event handlers
have run. The task will complete with `True` if the default action should be
permitted.  If any handler calls `preventDefault()`, the task will return
`False`. The task will fail if certain exceptions occur.

To dispatch an event from a sub-module, use the submodule's `toEvent` method.
For instance, to dispatch a `CustomEvent`, do something like:

    dispatchCustomEvent : Target -> CustomEvent -> Task String Bool
    dispatchCustomEvent target customEvent =
        WebAPI.Event.dispatch target (WebAPI.Event.CustomEvent.toEvent customEvent)
-}
dispatch : Target -> Event -> Task String Bool
dispatch = Native.WebAPI.Event.dispatch


{- ---------
   Listening
   --------- -}

{-| Opaque type which represents a Javascript object which can respond to
Javascript's `addEventListener()` and `removeEventListener()`.

To obtain a `Target`, see methods such as `WebAPI.Document.target` and
`WebAPI.Window.target`.
-}
type Target = Target


{-| A task which, when executed, uses Javascript's `addEventListener()` to add
a `Responder` to the `Target` for the event specified by the string (e.g. "click").

Succeeds with a `Listener`, which you can supply to `removeListener` if you
wish.

Note that no matter what string you provide for the event type, your
`Responder` will be supplied with an `Event` object. If you want a more
specific object (e.g. `BeforeUnloadEvent`, then see the more specific methods
in those modules.
-}
addListener : ListenerPhase -> String -> Responder Event -> Target -> Task x (Listener Event)
addListener = Native.WebAPI.Listener.add


{-| Convenience method for the usual case in which you call `addListener`
for the `Bubble` phase.
-}
on : String -> Responder Event -> Target -> Task x (Listener Event)
on = addListener Bubble


{-| Like `addListener`, but only responds to the event once, and the resulting
`Task` only succeeds when the event occurs (with the value of the event object).
Thus, your `Responder` method might not need to do anything.
-}
addListenerOnce : ListenerPhase -> String -> Responder Event -> Target -> Task x Event
addListenerOnce = Native.WebAPI.Listener.addOnce


{-| Like `addListenerOnce`, but supplies the default `Phase` (`Bubble`), and a
`Responder` that does nothing (so you merely chain the resulting `Task`).
-}
once : String -> Target -> Task x Event
once string target =
    addListenerOnce Bubble string noResponse target


{-| Opaque type representing an event handler. -}
type Listener event = Listener


{-| The type of the listener's event. -}
listenerType : Listener event -> String
listenerType = Native.WebAPI.Listener.eventName


{-| The responder used by the listener. -}
responder : Listener event -> Responder event
responder = Native.WebAPI.Listener.responder


{-| The listener's target. -}
target : Listener event -> Target
target = Native.WebAPI.Listener.target


{-| The phase in which a `Responder` can be invoked. Typically, you will want `Bubble`. -}
type ListenerPhase
    = Capture
    | Bubble


{-| The listener's phase. -}
listenerPhase : Listener event -> ListenerPhase
listenerPhase = Native.WebAPI.Listener.phase


{-| A task which will remove the supplied `Listener`.

Alternatively, you can return `remove` from your `Responder` method, and the
listener will be removed.
-}
removeListener : Listener event -> Task x ()
removeListener = Native.WebAPI.Listener.remove


{- ----------
   Responding
   ---------- -}


{-| A function which will be called each time an event occurs, in order to
determine how to respond to the event.

* The `event` parameter is the Javascript event object.
* The `Listener` is the listener which is responsible for this event.

Your function should return a list of responses which you would like to make
to the event.
-}
type alias Responder event =
    event -> Listener event -> List Response


{-| Opaque type which represents a response which you would like to make to an event. -}
type Response
    = Remove
    | Set String Json.Encode.Value
    | Send Signal.Message
    | PerformTask (Task () ())


{-| Indicates that you would like to set a property on the event object with
the specified key to the specified value.

Normally, you should not need this. However, there are some events which need
to be manipulated in this way -- for instance, setting the `returnValue` on the
`beforeunload` event.
-}
set : String -> Json.Encode.Value -> Response
set = Set


{-| Indicates that you would like to send a message in response to the event. -}
send : Signal.Message -> Response
send = Send


{-| Indicates that you would like to perform a `Task` in response to the event.

If the task is to send a message via `Signal.send`, then you can use `send` as
a convenience.
-}
performTask : Task () () -> Response
performTask = PerformTask


{-| Indicates that no longer wish to listen for this event on this target. -}
remove : Response
remove = Remove


-- The idea here is that we don't want to expose these tasks generally, since
-- they mutate the event, and we don't want to *arbitrarily* mutate the event.
-- We only want to mutate the event as part of a response. So, the callback
-- becomes a kind of effects interpreter, and we only expose the effects
-- here, rather than the raw tasks. So, in effect, these are tasks that can
-- only be performed at a certain moment.


{-| Indicates that you would like to prevent further propagation of the event. -}
stopPropagation : Event -> Response
stopPropagation = PerformTask << stopPropagationNative


stopPropagationNative : Event -> Task x ()
stopPropagationNative = Native.WebAPI.Event.stopPropagation


{-| Like `stopPropagation`, but also prevents other listeners on the current
target from being called.
-}
stopImmediatePropagation : Event -> Response
stopImmediatePropagation = PerformTask << stopImmediatePropagationNative


stopImmediatePropagationNative : Event -> Task x ()
stopImmediatePropagationNative = Native.WebAPI.Event.stopImmediatePropagation


{-| Cancels the standard behaviour of the event. -}
preventDefault : Event -> Response
preventDefault = PerformTask << preventDefaultNative


preventDefaultNative : Event -> Task x ()
preventDefaultNative = Native.WebAPI.Event.preventDefault


{-| A responder that does nothing. -}
noResponse : event -> Listener event -> List Response 
noResponse event listener = []


{- ----
   JSON
   ---- -}


{-| Encode an event. -}
encode : Event -> Json.Encode.Value
encode = WebAPI.Native.unsafeCoerce


{-| Decode an event. -}
decoder : Json.Decode.Decoder Event
decoder = Native.WebAPI.Event.decoder "Event"
