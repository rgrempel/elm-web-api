module WebAPI.Window
    ( alert, confirm, prompt
    , beforeUnload
    , confirmUnload, confirmUnloadOnce
    , onUnload, unloadOnce
    , target
    , isOnline, online
    , encodeURIComponent, decodeURIComponent
    , value
    ) where

{-| Facilities from the browser's `window` object.

See the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Window)

## Alerts and dialogs

@docs alert, confirm, prompt

## URIs

@docs encodeURIComponent, decodeURIComponent

## Online status

@docs isOnline, online

## Unloading

@docs beforeUnload, confirmUnload, confirmUnloadOnce, onUnload, unloadOnce

## Other Events

@docs target

## JSON

@docs value
-}


import Task exposing (Task)
import Json.Decode
import Json.Encode

import WebAPI.Event exposing (Target, Listener, Responder, Event, ListenerPhase(Bubble))
import WebAPI.Event.BeforeUnload exposing (BeforeUnloadEvent)

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


{- ----
   URIs
   ---- -}

{-| The browser's `encodeURIComponent()`. -}
encodeURIComponent : String -> String
encodeURIComponent = Native.WebAPI.Window.encodeURIComponent


{-| The browser's `decodeURIComponent()`. -}
decodeURIComponent : String -> String
decodeURIComponent = Native.WebAPI.Window.decodeURIComponent


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

    BeforeUnload.prompt "Your message" event

as one of your responses. Or, for more convenience, use `confirmUnload`.
-}
beforeUnload : Responder BeforeUnloadEvent -> Task x (Listener BeforeUnloadEvent)
beforeUnload responder =
    WebAPI.Event.BeforeUnload.on responder target


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
confirmUnload : String -> Task x (Listener BeforeUnloadEvent)
confirmUnload message =
    let
        responder event listener =
            [ WebAPI.Event.BeforeUnload.prompt message event
            ]

    in
        beforeUnload responder


{-| Like `confirmUnload`, but only responds once and then removes the listener. -}
confirmUnloadOnce : String -> Task x BeforeUnloadEvent
confirmUnloadOnce message =
    let
        responder event listener =
            [ WebAPI.Event.BeforeUnload.prompt message event
            ]

    in
        WebAPI.Event.BeforeUnload.addListenerOnce Bubble responder target


{-| A task which, when executed, listens for the 'unload' event.

Note that it is unclear how much you can actually accomplish within
the Elm architecture before the page actually unloads. Thus, you should
experiment with this if you use it, and see how well it works.
-}
onUnload : Responder Event -> Task x (Listener Event)
onUnload responder =
    WebAPI.Event.on "unload" responder target


{-| A task which, when executed, waits for the 'unload' event, and
then succeeds. To do something at that time, just chain additional
tasks.

Note that it is unclear how much you can actually accomplish within
the Elm architecture before the page actually unloads. Thus, you should
experiment with this if you use it, and see how well it works.
-}
unloadOnce : Task x Event
unloadOnce =
    WebAPI.Event.once "unload" target


{- ------------
   Other Events
   ------------ -}

{-| A target for responding to events sent to the `window` object. -}
target : Target
target = Native.WebAPI.Window.events


{- ----
   JSON
   ---- -}

{-| Access the Javascript `window` object via `Json.Decode`. -}
value : Task x Json.Decode.Value
value =
    -- We need to put this behind a Task, because `Json.Decode` executes
    -- immediately, and some of the things it could access are not constants.
    Task.succeed Native.WebAPI.Window.events
