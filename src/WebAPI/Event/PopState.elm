module WebAPI.Event.PopState
    ( PopStateEvent, construct, state 
    , toEvent, fromEvent
    , encode, decoder
    ) where


{-| The browser's `PopStateEvent'.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/PopStateEvent).

@docs PopStateEvent, construct, state
@docs toEvent, fromEvent
@docs encode, decoder
-}


import Json.Decode exposing ((:=))
import Json.Encode
import Task exposing (Task)

import WebAPI.Event
import WebAPI.Native

import Native.WebAPI.Event


{- -------------
   PopStateEvent
   ------------- -}


{-| Opaque type representing a PopStateEvent. -}
type PopStateEvent = PopStateEvent


{-| Create a `PopStateEvent` with the given state and options. -}
construct : Json.Encode.Value -> WebAPI.Event.Options -> Task x PopStateEvent
construct = Native.WebAPI.Event.popStateEvent


{-| Get the state. -}
state : PopStateEvent -> Json.Decode.Value
state event =
    let
        result =
            Json.Decode.decodeValue
                ("state" := Json.Decode.value) 
                (encode event)

    in
        Result.withDefault Json.Encode.null result


{- ----------
   Conversion
   ---------- -}


{-| Convert to an `Event` in order to use `Event` functions. -}
toEvent : PopStateEvent -> WebAPI.Event.Event
toEvent = WebAPI.Native.unsafeCoerce


{-| Convert from an `Event`. -}
fromEvent : WebAPI.Event.Event -> Maybe PopStateEvent
fromEvent event =
    Result.toMaybe <|
        Json.Decode.decodeValue decoder (WebAPI.Event.encode event)


{- ----
   JSON
   ---- -}


{-| Encode a PopStateEvent. -}
encode : PopStateEvent -> Json.Encode.Value
encode = WebAPI.Native.unsafeCoerce


{-| Decode a PopStateEvent. -}
decoder : Json.Decode.Decoder PopStateEvent
decoder = Native.WebAPI.Event.decoder "PopStateEvent"
