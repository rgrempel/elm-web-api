module WebAPI.Event.UI
    ( UIEvent, detail
    , options, defaultOptions
    , toEvent, fromEvent
    , encode, decoder
    ) where


{-| The browser's `UIEvent'.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/UIEvent).

Note that at least Safari and Firefox seem to put more properties at the
UIEvent level and less in the more specific event types, compared with Internet
Explorer. I've followed what IE does here for compatibility, and because it
seems more consistent with the standard:

http://www.w3.org/TR/DOM-Level-3-Events

However, this should work fine with Safari and Firefox as well, since the relevant
properties etc. will still be available on the more specific events.

@docs UIEvent, detail
@docs options, defaultOptions
@docs toEvent, fromEvent
@docs encode, decoder
-}

import Json.Decode exposing ((:=))
import Json.Encode
import Task exposing (Task)

import WebAPI.Event exposing (Event, ListenerPhase(Bubble), Responder, Response, Target, Listener, noResponse)
import WebAPI.Event.Internal exposing (Selector(Selector), Options(Options))
import WebAPI.Native
import Native.WebAPI.Event


{- -------
   UIEvent
   ------- -}


{-| Opaque type representing a UIEvent. -}
type UIEvent = UIEvent


{-| Data set when the `UIEvent` was created. -}
detail : UIEvent -> Int
detail event =
    let
        result =
            Json.Decode.decodeValue
                ("detail" := Json.Decode.int)
                (encode event)

    in
        -- In principle, all UIEvents should have a detail field. At least in Safari,
        -- if you don't supply one on creation, you get a 0. So, let's emulate that
        -- in case anyone supplies a null.
        Result.withDefault 0 result


{-| Specify options for creating a `UIEvent` with the given detail. -}
options : Int -> Options Event -> Options UIEvent
options value (Options list _) =
    Options
        (list ++ [ ("detail", Json.Encode.int value) ])
        "CustomEvent"


{-| Specify options for creating a `UIEvent` with a detail of 0. -}
defaultOptions : Options Event -> Options UIEvent
defaultOptions =
    options 0


{- ----------
   Conversion
   ---------- -}


{-| Convert to an `Event` in order to use `Event` functions. -}
toEvent : UIEvent -> Event
toEvent = WebAPI.Native.unsafeCoerce


{-| Convert from an `Event`. -}
fromEvent : Event -> Maybe UIEvent
fromEvent event =
    Result.toMaybe <|
        Json.Decode.decodeValue decoder (WebAPI.Event.encode event)


{- ----
   JSON
   ---- -}


{-| Encode a UIEvent. -}
encode : UIEvent -> Json.Encode.Value
encode = WebAPI.Native.unsafeCoerce


{-| Decode a UIEvent. -}
decoder : Json.Decode.Decoder UIEvent
decoder = WebAPI.Event.Internal.decoder "UIEvent"
