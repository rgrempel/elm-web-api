module WebAPI.Event.Custom
    ( CustomEvent, detail, construct
    , addListener, on, addListenerOnce, once
    , toEvent, fromEvent
    , encode, decoder
    ) where


{-| The browser's `CustomEvent'.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent).

@docs CustomEvent, detail
@docs construct, dispatch
@docs addListener, on, addListenerOnce, once
@docs toEvent, fromEvent
@docs encode, decoder
-}

import Json.Decode exposing ((:=))
import Json.Encode
import Task exposing (Task)

import WebAPI.Event exposing (Event, ListenerPhase(Bubble), Responder, Response, Target, Listener, noResponse)
import WebAPI.Event.Internal
import WebAPI.Native
import Native.WebAPI.Event


{- -----------
   CustomEvent
   ----------- -}


{-| Opaque type representing a CustomEvent. -}
type CustomEvent = CustomEvent


{-| Data set when the `CustomEvent` was created. -}
detail : CustomEvent -> Json.Decode.Value
detail event =
    let
        result =
            Json.Decode.decodeValue
                ("detail" := Json.Decode.value)
                (encode event)

    in
        -- In principle, all CustomEvents should have a detail field. However,
        -- if they don't, it seems reasonable to say that it was null.
        Result.withDefault Json.Encode.null result


{-| Create a `CustomEvent` with the given eventType, detail and options. -}
construct : String -> Json.Encode.Value -> WebAPI.Event.Options -> Task x CustomEvent
construct = Native.WebAPI.Event.customEvent


{- ---------
   Listening
   --------- -}


{-| Listen for a `CustomEvent` with the given event name. -}
addListener : ListenerPhase -> String -> Responder CustomEvent -> Target -> Task x (Listener CustomEvent)
addListener phase =
    WebAPI.Event.Internal.addListener phase


{-| Listen for a `CustomEvent` in the `Bubble` phase. -}
on : String -> Responder CustomEvent -> Target -> Task x (Listener CustomEvent)
on = addListener Bubble


{-| Listen for a `CustomEvent` once. -}
addListenerOnce : ListenerPhase -> String -> Responder CustomEvent -> Target -> Task x CustomEvent
addListenerOnce phase =
    WebAPI.Event.Internal.addListenerOnce phase


{-| Listen for a `CustomEvent` once in the `Bubble` phase. -}
once : String -> Target -> Task x CustomEvent
once string target =
    addListenerOnce Bubble string noResponse target


{- ----------
   Conversion
   ---------- -}


{-| Convert to an `Event` in order to use `Event` functions. -}
toEvent : CustomEvent -> Event
toEvent = WebAPI.Native.unsafeCoerce


{-| Convert from an `Event`. -}
fromEvent : Event -> Maybe CustomEvent
fromEvent event =
    Result.toMaybe <|
        Json.Decode.decodeValue decoder (WebAPI.Event.encode event)


{- ----
   JSON
   ---- -}


{-| Encode a CustomEvent. -}
encode : CustomEvent -> Json.Encode.Value
encode = WebAPI.Native.unsafeCoerce


{-| Decode a CustomEvent. -}
decoder : Json.Decode.Decoder CustomEvent
decoder = WebAPI.Event.Internal.decoder "CustomEvent"
