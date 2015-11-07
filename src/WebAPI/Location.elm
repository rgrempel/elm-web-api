module WebAPI.Location
    ( Location, location
    , reload, Source(ForceServer, AllowCache)
    , assign, replace
    ) where


{-| Facilities from the browser's `window.location` object.

See the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Location)

For a `Signal`-oriented version of things you might do with `window.location`, see
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).

@docs Location, location, reload, Source, assign, replace
-}


import Task exposing (Task)
import Native.WebAPI.Location


{-| The parts of a location object. Note `port'`, since `port` is a reserved word. -}
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


{-| The browser's `window.location` object. -}
location : Task x Location
location = Native.WebAPI.Location.location 


{-| Reloads the page from the current URL.-}
reload : Source -> Task String ()
reload source =
    nativeReload <|
        case source of
            ForceServer -> True
            AllowCache -> False


nativeReload : Bool -> Task String ()
nativeReload = Native.WebAPI.Location.reload


{-| Whether to force `reload` to use the server, or allow the cache. -}
type Source
    = ForceServer
    | AllowCache


{-| A task which, when executed, loads the resource at the provided URL,
or provides an error message upon failure.

Note that only Firefox appears to reliably report an error -- other browsers
silently fail if an invalid URL is provided.

Also consider using `setPath` from
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).
-}
assign : String -> Task String ()
assign = Native.WebAPI.Location.assign


{-| Like `assign`, loads the resource at the provided URL, but replaces the
current page in the browser's history.

Note that only Firefox appears to reliably report an error -- other browsers
silently fail if an invalid URL is provided.

Also consider using `replacePath` from
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).
-}
replace : String -> Task String ()
replace = Native.WebAPI.Location.replace
