module WebAPI.Event.Internal
    ( Selector (Selector)
    , Options (Options)
    , decoder
    ) where


{-| This is a module for some things which we want to export, so they can
be used in multiple modules internally, but which we don't want to make
visible to clients -- so, this module is not among the 'exposed-modules'
in elm-package.json.
 
@docs selector
@docs decoder
-}

import Json.Decode
import Json.Encode

import Native.WebAPI.Event


{-| Binds together an event name and an event type. The idea is that we only
allow the creation of selectors that bind the appropriate event names with the
appropriate event types.
-}
type Selector event = Selector String


{-| Represents an object to be used to construct an event. The first value is a
list of parameters, in the order that init... expects them. The second value is
the Javascript class name.
-}
type Options event = Options (List (String, Json.Encode.Value)) String


{-| Decode an event with the given type. -}
decoder : String -> Json.Decode.Decoder event
decoder = Native.WebAPI.Event.decoder
