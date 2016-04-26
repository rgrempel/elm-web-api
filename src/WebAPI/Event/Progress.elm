module WebAPI.Event.Progress
    ( ProgressEvent, construct, lengthComputable, loaded, total 
    , toEvent, fromEvent
    , encode, decoder
    ) where


{-| The browser's `ProgressEvent'.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/ProgressEvent).

@docs ProgressEvent, construct, lengthComputable, loaded, total
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
   ProgressEvent
   ------------- -}


{-| Opaque type representing a ProgressEvent. -}
type ProgressEvent = ProgressEvent


{-| Options for creating a `ProgressEvent`. -}
type alias Options =
    { lengthComputable : Bool
    , loaded : Int
    , total : Int
    }


{-| Create a `ProgressEvent` with the given state and options. -}
construct : Options -> WebAPI.Event.Options -> Task x ProgressEvent
construct = Native.WebAPI.Event.progressEvent


{-| Is the length computable? -}
lengthComputable : ProgressEvent -> Bool
lengthComputable event =
    let
        result =
            Json.Decode.decodeValue
                ("length" := Json.Decode.bool) 
                (encode event)

    in
        Result.withDefault False result


{-| How much progress has been made? -}
loaded : ProgressEvent -> Float 
loaded event =
    let
        result =
            Json.Decode.decodeValue
                ("loaded" := Json.Decode.float) 
                (encode event)

    in
        Result.withDefault 0 result


{-| How much work is there in total? -}
total : ProgressEvent -> Float
total event =
    let
        result =
            Json.Decode.decodeValue
                ("total" := Json.Decode.float) 
                (encode event)

    in
        Result.withDefault 0 result


{- ----------
   Conversion
   ---------- -}


{-| Convert to an `Event` in order to use `Event` functions. -}
toEvent : ProgressEvent -> WebAPI.Event.Event
toEvent = WebAPI.Native.unsafeCoerce


{-| Convert from an `Event`. -}
fromEvent : WebAPI.Event.Event -> Maybe ProgressEvent
fromEvent event =
    Result.toMaybe <|
        Json.Decode.decodeValue decoder (WebAPI.Event.encode event)


{- ----
   JSON
   ---- -}


{-| Encode a ProgressEvent. -}
encode : ProgressEvent -> Json.Encode.Value
encode = WebAPI.Native.unsafeCoerce


{-| Decode a ProgressEvent. -}
decoder : Json.Decode.Decoder ProgressEvent
decoder = Native.WebAPI.Event.decoder "ProgressEvent"
