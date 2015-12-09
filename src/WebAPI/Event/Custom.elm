module WebAPI.Event.Custom
    ( CustomEvent, detail, construct, select
    , toEvent, fromEvent
    , encode, decoder
    ) where


{-| The browser's `CustomEvent'.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent).

@docs CustomEvent, detail
@docs construct, select
@docs toEvent, fromEvent
@docs encode, decoder
-}

import Json.Decode exposing ((:=))
import Json.Encode
import Task exposing (Task)

import WebAPI.Event exposing (Event, ListenerPhase(Bubble), Responder, Response, Target, Listener, noResponse)
import WebAPI.Event.Internal exposing (Selector(Selector))
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


{-| Create a `CustomEvent` with the given event type, detail and options. -}
construct : String -> Json.Encode.Value -> WebAPI.Event.Options -> Task x CustomEvent
construct = Native.WebAPI.Event.customEvent


{-| Select a `CustomEvent` with the given event type. -}
select : String -> Selector CustomEvent
select = Selector


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
