module Main where

import Signal exposing (Signal, Mailbox, mailbox, constant, send)
import Task exposing (Task, andThen, sequence)
import Graphics.Element exposing (Element)
import ElmTest.Runner.Element exposing (runDisplay)
import Tests

import WebAPI.MathTest
import WebAPI.NumberTest
import WebAPI.StorageTest
import WebAPI.ScreenTest


main : Signal Element
main =
    Signal.map runDisplay (.signal Tests.tests)


port task : Task () ()
port task = Tests.task

