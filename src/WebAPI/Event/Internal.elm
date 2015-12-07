module WebAPI.Event.Internal
    ( addListener, on, addListenerOnce, once
    , decoder
    ) where


{-| This is a module for event stuff that is used internally by multiple event
modules. So, the methods need to be exposed, but the module as a whole is not
exposed to clients.

The point of this is essentially a puzzle about how to model some type
constraints.

If we expose these methods while allowing any string for the event type, then
we've basically said that you can supply a handler which accepts any event
type for any string. Yet, that's not really true ... for instance, if you
supply a handler for a `PopState` event, and yet use 'click' as your event
name, then you're not really going to get a `PopState` event supplied to
your handler.

Of course, we could require you to decode the event at run-time and handle
failure, but it would be nice to do better.

So, what we do is only expose specific string eventTypes for specific event
types.  That way, the event types line up with the event objects you will
actually receive.

To make this easier, we have generic versions here that we can use internally.
But they rely on a proper correspondence between the string eventTypes and the
event type that is generically expected. That is, they rely on the generic type
being parameterized correctly for the string. So, that's why we don't expose
them to clients.

The two exceptions, in a way, are `Event` and `CustomEvent`.

`Event` is an exception because every event is an `Event` -- so, it is OK to
expect an `Event` no matter what string type you're listening for.

`CustomEvent` is an exception because its only specialization is a `detail`
field, which is a `JE.Value`, so you have to interpret it anyway -- if it is
not there, the decoder will just fail, which you have to handle anyway. So,
even if your handler gets the wrong event type (that is, expecting
`CustomEvent` but you get something else) it should be fine. Plus, it wouldn't
make any sense to limit `CustomEvent` to pre-defined event strings, since the
whole point is that you can make them up ...

To put this all another way, in the type signatures below, we imply that the
methods can handle any 'event' type. But that's not really true -- the string
must be appropriate to the event type. So, we guarantee they correspond by
only exposing (to the client) methods where they do correspond -- that is, where
the string and the specialization of `event` match properly.

@docs addListener, on, addListenerOnce, once
@docs decoder
-}

import Json.Decode
import Task exposing (Task)

import WebAPI.Event exposing (..)
import Native.WebAPI.Event
import Native.WebAPI.Listener


{-| A task which, when executed, uses Javascript's `addEventListener()` to add
a `Responder` to the `Target` for the event specified by the string (e.g. "click").

Succeeds with a `Listener`, which you can supply to `removeListener` if you
wish.
-}
addListener : ListenerPhase -> String -> Responder event -> Target -> Task x (Listener event)
addListener = Native.WebAPI.Listener.add


{-| Convenience method for the usual case in which you call `addListener`
for the `Bubble` phase.
-}
on : String -> Responder event -> Target -> Task x (Listener event)
on = addListener Bubble


{-| Like `addListener`, but only responds to the event once, and the resulting
`Task` only succeeds when the event occurs (with the value of the event object).
Thus, your `Responder` method might not need to do anything.
-}
addListenerOnce : ListenerPhase -> String -> Responder event -> Target -> Task x event
addListenerOnce = Native.WebAPI.Listener.addOnce


{-| Like `addListenerOnce`, but supplies the default `Phase` (`Bubble`), and a
`Responder` that does nothing (so you merely chain the resulting `Task`).
-}
once : String -> Target -> Task x event
once string target =
    addListenerOnce Bubble string noResponse target


{-| Decode an event with the given type. -}
decoder : String -> Json.Decode.Decoder event
decoder = Native.WebAPI.Event.decoder
