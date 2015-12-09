module WebAPI.Document
    ( ReadyState (Loading, Interactive, Complete)
    , readyState, getReadyState
    , domContentLoaded, loaded
    , getTitle, setTitle
    , target
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

@docs target

## JSON

@docs value
-}


import Signal exposing (Signal)
import Task exposing (Task, andThen)
import Json.Decode
import Json.Encode

import WebAPI.Event exposing (Target, Listener, Responder, Event)

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
                    WebAPI.Event.once (WebAPI.Event.select "DOMContentLoaded") target

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
                    WebAPI.Event.once (WebAPI.Event.select "load") target
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

{-| A target for responding to events sent to the `document` object. -}
target : Target
target = Native.WebAPI.Document.events


{- ----
   JSON
   ---- -}

{-| Access the Javascript `document` object via `Json.Decode`. -}
value : Task x Json.Decode.Value
value =
    -- We need to put this behind a Task, because `Json.Decode` executes
    -- immediately, and some of the things it could access are not constants
    Task.succeed Native.WebAPI.Document.events
