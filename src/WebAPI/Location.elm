module WebAPI.Location
    ( Location, location, reload
    ) where


{-| Facilities from the browser's `window.location` object.

See the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Location)

For a `Signal`-oriented version of things you might do with `window.location`, see
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).

For `assign`, use `setPath` from
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).

For `replace`, use `replacePath` from
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).

@docs Location, location, reload
-}


import Task exposing (Task)
import Native.WebAPI.Location


type alias Location =
    { href: String
    , protocol: String
    , host: String
    , hostname: String
    , port': String
    , pathname: String
    , search: String
    , hash: String
    , origin: String
    }


location : Task x Location
location = Native.WebAPI.Location.location 


reload : Bool -> Task String ()
reload = Native.WebAPI.Location.reload
