module WebAPI.Screen
    ( Screen, screen
    ) where


{-| The browser's `Screen` type from `window.screen`.

See the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Screen).

@docs Screen, screen
-}

import Task exposing (Task)

import Native.WebAPI.Screen


{-| The browser's `Screen` type. -}
type alias Screen =
    { availTop: Int
    , availLeft: Int
    , availHeight: Int
    , availWidth: Int
    , colorDepth: Int
    , pixelDepth: Int
    , height: Int
    , width: Int
    }


{-| The browser's `window.screen` object.

This is a `Task` because in multi-monitor setups, the result depends on which screen
the browser window is in. So, it is not necessarily a constant.
-}
screen : Task x Screen
screen = Native.WebAPI.Screen.screen
