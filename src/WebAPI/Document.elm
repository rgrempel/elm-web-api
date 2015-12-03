module WebAPI.Document
    ( ReadyState (Loading, Interactive, Complete)
    , readyState, getReadyState
    , domContentLoaded, loaded
    , getTitle, setTitle
    , events, on, once
    , value
    ) where

{-| See Mozilla documentation for the
[`Document` object](https://developer.mozilla.org/en-US/docs/Web/API/Document).

## Loading

@docs ReadyState, readyState, getReadyState
@docs domContentLoaded, loaded

## Title

@docs getTitle, setTitle

## Events

@docs on, once, events

## JSON

@docs value
-}


import Signal exposing (Signal)
import Task exposing (Task, andThen)
import Json.Decode
import Json.Encode
import WebAPI.Event
import Native.WebAPI.Document


{- -------
   Loading
   ------- -}

{-| Possible values for the browser's `document.readyState` -}
type ReadyState
    = Loading
    | Interactive
    | Complete


{-| A `Signal` of changes to the browser's `document.readyState` -}
readyState : Signal ReadyState
readyState = Native.WebAPI.Document.readyState


{-| A task which, when executed, succeeds with the value of the browser's
`document.readyState`.
-}
getReadyState : Task x ReadyState
getReadyState = Native.WebAPI.Document.getReadyState


{-| A task which succeeds when the `DOMContentLoaded` event fires. If that
event has already fired, then this succeeds immediately.

Note that you won't usually need this in the typical Elm application in which
it is Elm itself that generates most of the DOM. In that case, you'll just
want to make some `Task` run when the app starts up. If you're using
`StartApp`, then that would be accomplished by supplying an `Effects` as part
of the `init` when you call `StartApp.start`.
-}
domContentLoaded : Task x ()
domContentLoaded =
    -- First we check whether it has already fired. It corresponds to the
    -- `Interactive` readyState, according to
    -- https://developer.mozilla.org/en/docs/web/api/document/readystate
    getReadyState `andThen` (\state ->
        if state == Loading
            then
                -- If it hasn't fired yet, listen for it
                Task.map (always ()) <|
                    once "DOMContentLoaded"

            else
                Task.succeed ()
    )


{-| A task which succeeds when the `load` event fires. If that event has
already fired, then this succeeds immediately.
-}
loaded : Task x ()
loaded =
    -- First we check whether it has already fired. It corresponds to the
    -- `Complete` readyState, according to
    -- https://developer.mozilla.org/en/docs/web/api/document/readystate
    getReadyState `andThen` (\state ->
        if state == Complete
            then
                Task.succeed ()

            else
                -- If it hasn't fired yet, listen for it
                Task.map (always ()) <|
                    once "load"
    )


{- ------
   Titles
   ------ -}

{-| A task which, when executed, succeeds with the value of `document.title`. -}
getTitle : Task x String
getTitle = Native.WebAPI.Document.getTitle


{-| A task which, when executed, sets the value of `document.title` to the
supplied `String`.
-}
setTitle : String -> Task x ()
setTitle = Native.WebAPI.Document.setTitle


{- ------
   Events
   ------ -}

{-| A target for responding to events sent to the `document` object. Normally,
it will be simpler to use `on`, but you may need this in some cases.
-}
events : WebAPI.Event.Target
events = Native.WebAPI.Document.events


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

{-| Access the Javascript `document` object via `Json.Decode`. -}
value : Task x Json.Decode.Value
value =
    -- We need to put this behind a Task, because `Json.Decode` executes
    -- immediately, and some of the things it could access are not constants
    Task.succeed Native.WebAPI.Document.events
