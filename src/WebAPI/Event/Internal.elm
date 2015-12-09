module WebAPI.Event.Internal
    ( Selector (Selector)
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

import Native.WebAPI.Event


{-| Binds together an event name and an event type. The idea is that we only
allow the creation of selectors that bind the appropriate event names with the
appropriate event types.
-}
type Selector event = Selector String


{-| Decode an event with the given type. -}
decoder : String -> Json.Decode.Decoder event
decoder = Native.WebAPI.Event.decoder
