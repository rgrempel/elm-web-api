module WebAPI.WindowTest where

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)
import ElmTest.Runner.Element exposing (runDisplay)

import Task exposing (Task, andThen, sequence, map)

import WebAPI.Window as Window


(>>>) = flip Task.map
(>>+) = Task.andThen


isOnline : Task x Test
isOnline =
    Window.isOnline >>> (assert >> test "isOnline should be true")
    

tests : Task () Test
tests =
    Task.map (suite "WebAPI.WindowTest") <|
        sequence
            [ isOnline
            ]
