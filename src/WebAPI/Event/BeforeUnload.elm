module WebAPI.Event.BeforeUnload
    ( BeforeUnloadEvent, prompt, select
    , toEvent, fromEvent
    , encode, decoder
    ) where


{-| The browser's `BeforeUnloadEvent'.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/BeforeUnloadEvent).

See `WebAPI.Window.beforeUnload` and `WebAPI.Window.confirmUnload` for a
higher-level, more convenient API.

@docs BeforeUnloadEvent, prompt, select
@docs toEvent, fromEvent
@docs encode, decoder
-}

import Json.Decode
import Json.Encode
import Task exposing (Task)

import WebAPI.Event exposing (Event, ListenerPhase(Bubble), Responder, Response, Target, Listener, noResponse)
import WebAPI.Event.Internal exposing (Selector(Selector))
import WebAPI.Native
import Native.WebAPI.Event


{- -----------------
   BeforeUnloadEvent
   ----------------- -}


{-| Opaque type representing a BeforeUnloadEvent. -}
type BeforeUnloadEvent = BeforeUnloadEvent


{-| Select the 'beforeunload' event. -}
select : Selector BeforeUnloadEvent
select = Selector "beforeunload"


{- ----------
   Responding
   ---------- -}


{-| Provide a prompt to use in the confirmation dialog box before leaving tha page. -}
prompt : String -> BeforeUnloadEvent -> Response
prompt string event =
    -- Note that event is ignored -- it's essentially for type safety
    WebAPI.Event.set "returnValue" <|
        Json.Encode.string string


{- ----------
   Conversion
   ---------- -}


{-| Convert to an `Event` in order to use `Event` functions. -}
toEvent : BeforeUnloadEvent -> Event
toEvent = WebAPI.Native.unsafeCoerce


{-| Convert from an `Event`. -}
fromEvent : Event -> Maybe BeforeUnloadEvent
fromEvent event =
    Result.toMaybe <|
        Json.Decode.decodeValue decoder (WebAPI.Event.encode event)


{- ----
   JSON
   ---- -}


{-| Encode a BeforeUnloadEvent. -}
encode : BeforeUnloadEvent -> Json.Encode.Value
encode = WebAPI.Native.unsafeCoerce


{-| Decode a BeforeUnloadEvent. -}
decoder : Json.Decode.Decoder BeforeUnloadEvent
decoder = WebAPI.Event.Internal.decoder "BeforeUnloadEvent"
