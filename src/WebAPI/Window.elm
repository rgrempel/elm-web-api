module WebAPI.Window
    ( alert, confirm, prompt
    , beforeUnload, confirmUnload
    , onUnload, unload
    , on, once, events
    , isOnline, online
    , value
    ) where

{-| Facilities from the browser's `window` object.

See the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Window)

## Alerts and dialogs

@docs alert, confirm, prompt

## Online status

@docs isOnline, online

## Unloading

@docs confirmUnload, beforeUnload, unload, onUnload

## Events

@docs on, once, events

## JSON

@docs value
-}


import Task exposing (Task)
import Json.Decode
import Json.Encode
import WebAPI.Event
import Native.WebAPI.Window


{- ------------------
   Alerts and dialogs
   ------------------ -}

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


{- -------------
   Online status
   ------------- -}

{-| Whether the browser is online, according to `navigator.onLine` -}
isOnline : Task x Bool
isOnline = Native.WebAPI.Window.isOnline


{-| A `Signal` indicating whether the browser is online, according to `navigator.onLine` -}
online : Signal Bool
online = Native.WebAPI.Window.online


{- ---------
   Unloading
   --------- -}

{-| A task which, when executed, listens for the `BeforeUnload` event.

To set up a confirmation dialog, have your responder return

    WebAPI.Event.set "returnValue" (Json.Encode.encodeString "Your confimration message")

as one of your responses. Or, for more convenience, use `confirmBeforeUnload`.
-}
beforeUnload : WebAPI.Event.Responder a b -> Task x WebAPI.Event.Listener
beforeUnload responder =
    on "beforeunload" responder


{-| A task which, when executed, listens for the page to be unloaded, and
requires confirmation to do so.

In order to stop requiring confirmation, use `WebAPI.Event.removeListener` on
the resulting listener.

If you need to change the confirmation message, then you will need to use
`WebAPI.Event.removeListener` to remove any existing listener, and then use
this again to set up a new one.

If you need to do anything more complex when `BeforeUnload` fires, then see
`beforeUnload`.
-}
confirmUnload : String -> Task x WebAPI.Event.Listener
confirmUnload message =
    let
        responder event listener =
            [ WebAPI.Event.set "returnValue" <|
                Json.Encode.string message
            ]

    in
        beforeUnload responder


{-| A task which, when executed, listens for the 'unload' event.

Note that it is unclear how much you can actually accomplish within
the Elm architecture before the page actually unloads. Thus, you should
experiment with this if you use it, and see how well it works.
-}
onUnload : WebAPI.Event.Responder a b -> Task x WebAPI.Event.Listener
onUnload responder =
    on "unload" responder


{-| A task which, when executed, waits for the 'unload' event, and
then succeeds. To do something at that time, just chain additional
tasks.

Note that it is unclear how much you can actually accomplish within
the Elm architecture before the page actually unloads. Thus, you should
experiment with this if you use it, and see how well it works.
-}
unload : Task x ()
unload =
    Task.map (always ()) <|
        once "unload"


{- ------
   Events
   ------ -}

{-| A target for responding to events sent to the `window` object. Normally,
it will be simpler to use `on`, but you may need this in some cases.
-}
events : WebAPI.Event.Target
events = Native.WebAPI.Window.events


{-| A task which, when executed, uses Javascript's `addEventListener()` to
respond to events specified by the string (e.g. "click").
-}
on : String -> WebAPI.Event.Responder a b -> Task x WebAPI.Event.Listener
on eventName responder =
    WebAPI.Event.on eventName responder events


{-| Like `on`, but only succeeds once the event occurs (with the value of the
event object), and then stops listening.
-}
once : String -> Task x Json.Decode.Value
once eventName =
    WebAPI.Event.once eventName events


{- ----
   JSON
   ---- -}

{-| Access the Javascript `window` object via `Json.Decode`. -}
value : Json.Decode.Value
value = Native.WebAPI.Window.events
