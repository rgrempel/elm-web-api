module WebAPI.Event.PageTransition
    ( PageTransitionEvent, persisted, construct 
    , EventType(PageShow, PageHide), eventType
    , toEvent, fromEvent
    , encode, decoder
    ) where


{-| The browser's `PageTransitionEvent'.

Note that Internet Explorer does not support the `oldUrl` or `newUrl`
properties, so they are not exposed here. Of course, you can get them via
`encode` and then `Json.Decode.decodeValue` if you like.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/PageTransitionEvent).

@docs PageTransitionEvent, construct, persisted
@docs EventType, eventType
@docs toEvent, fromEvent
@docs encode, decoder
-}


import Json.Decode exposing ((:=))
import Json.Encode
import Task exposing (Task)

import WebAPI.Event
import WebAPI.Native

import Native.WebAPI.Event


{- -------------------
   PageTransitionEvent
   ------------------- -}


{-| Opaque type representing a PageTransitionEvent. -}
type PageTransitionEvent = PageTransitionEvent


{-| Event types associated with `PageTransitionEvent`. -}
type EventType
    = PageShow
    | PageHide


{-| Create a `PageTransitionEvent` with the given event type.

The second parameter represents whether the page has been persisted (cached).

Note that `oldUrl` and `newUrl` are not exposed here, because Internet Explorer
does not support them.
-}
construct : EventType -> Bool -> WebAPI.Event.Options -> Task x PageTransitionEvent
construct = Native.WebAPI.Event.pageTransitionEvent


{-| Indicates whether the page is cached. -}
persisted : PageTransitionEvent -> Bool
persisted event =
    let
        result =
            Json.Decode.decodeValue
                ("persisted" := Json.Decode.bool)
                (encode event)

    in
        Result.withDefault False result


{-| The event type. -}
eventType : PageTransitionEvent -> EventType
eventType pte =
    case WebAPI.Event.eventType (toEvent pte) of
        "pageshow" -> PageShow
        "pagehide" -> PageHide
        _ -> Debug.crash "Invalid event type for PageTransitionEvent"
    

{- ----------
   Conversion
   ---------- -}


{-| Convert to an `Event` in order to use `Event` functions. -}
toEvent : PageTransitionEvent -> WebAPI.Event.Event
toEvent = WebAPI.Native.unsafeCoerce


{-| Convert from an `Event`. -}
fromEvent : WebAPI.Event.Event -> Maybe PageTransitionEvent
fromEvent event =
    Result.toMaybe <|
        Json.Decode.decodeValue decoder (WebAPI.Event.encode event)


{- ----
   JSON
   ---- -}


{-| Encode a PageTransitionEvent. -}
encode : PageTransitionEvent -> Json.Encode.Value
encode = WebAPI.Native.unsafeCoerce


{-| Decode a PageTransitionEvent. -}
decoder : Json.Decode.Decoder PageTransitionEvent
decoder = Native.WebAPI.Event.decoder "PageTransitionEvent"
