module WebAPI.Window
    ( alert, confirm, prompt
    , isOnline, online
    ) where

{-| Facilities from the browser's `window` object.

See the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Window)

## Alerts and dialogs

@docs alert, confirm, prompt

## Online status

@docs isOnline, online
-}


import Task exposing (Task)
import Json.Decode
import Json.Encode
import Native.WebAPI.Window


{-| The browser's `window.alert()` function. -}
alert : String -> Task x ()
alert = Native.WebAPI.Window.alert


{-| The browser's `window.confirm()` function.

The task will succeed if the user confirms, and fail if the user cancels.
-}
confirm : String -> Task () ()
confirm = Native.WebAPI.Window.confirm


{-| The browser's `window.prompt()` function.

The first parameter is a message, and the second parameter is a default
response.

The task will succeed with the user's response, or fail if the user cancels
or enters blank text.
-}
prompt : String -> String -> Task () String
prompt = Native.WebAPI.Window.prompt


{-| Whether the browser is online, according to `navigator.onLine` -}
isOnline : Task x Bool
isOnline = Native.WebAPI.Window.isOnline


{-| A `Signal` indicating whether the browser is online, according to `navigator.onLine` -}
online : Signal Bool
online = Native.WebAPI.Window.online
