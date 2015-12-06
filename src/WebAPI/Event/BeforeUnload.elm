module WebAPI.Event.BeforeUnload
    ( BeforeUnloadEvent, prompt
    , addListener, on, addListenerOnce, once
    , toEvent, fromEvent
    , encode, decoder
    ) where


{-| The browser's `BeforeUnloadEvent'.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/BeforeUnloadEvent).

See `WebAPI.Window.beforeUnload` and `WebAPI.Window.confirmUnload` for a
higher-level, more convenient API.

@docs BeforeUnloadEvent, prompt
@docs addListener, on, addListenerOnce, once
@docs toEvent, fromEvent
@docs encode, decoder
-}

import Json.Decode
import Json.Encode
import Task exposing (Task)

import WebAPI.Event exposing (ListenerPhase(Bubble), Responder, Response, Target, Listener, noResponse)
import WebAPI.Event.Internal
import WebAPI.Native
import Native.WebAPI.Event


{-| Opaque type representing a BeforeUnloadEvent. -}
type BeforeUnloadEvent = BeforeUnloadEvent


{- ---------
   Listening
   --------- -}


{-| Listen for the `beforeunload` event. -}
addListener : ListenerPhase -> Responder BeforeUnloadEvent -> Target -> Task x (Listener BeforeUnloadEvent)
addListener phase =
    WebAPI.Event.Internal.addListener phase "beforeunload"


{-| Listen for the `beforeunload` event in the `Bubble` phase. -}
on : Responder BeforeUnloadEvent -> Target -> Task x (Listener BeforeUnloadEvent)
on = addListener Bubble


{-| Listen for the `beforeunload` event once. -}
addListenerOnce : ListenerPhase -> Responder BeforeUnloadEvent -> Target -> Task x BeforeUnloadEvent
addListenerOnce phase =
    WebAPI.Event.Internal.addListenerOnce phase "beforeunload"


{-| Listen for the `beforeunload` event once in the `Bubble` phase. -}
once : Target -> Task x BeforeUnloadEvent
once target =
    addListenerOnce Bubble noResponse target


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
toEvent : BeforeUnloadEvent -> WebAPI.Event.Event
toEvent = WebAPI.Native.unsafeCoerce


{-| Convert from an `Event`. -}
fromEvent : WebAPI.Event.Event -> Maybe BeforeUnloadEvent
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
decoder = Native.WebAPI.Event.decoder "BeforeUnloadEvent"
