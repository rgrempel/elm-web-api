module Main where

import Signal exposing (Signal, Mailbox, mailbox, constant, send)
import Task exposing (Task, andThen, sequence)
import Graphics.Element exposing (Element)
import ElmTest.Test exposing (..)
import ElmTest.Runner.Element exposing (runDisplay)

import WebAPI.MathTest
import WebAPI.NumberTest


main : Signal Element
main =
    Signal.map runDisplay tests.signal


tests : Mailbox Test
tests =
    mailbox (suite "Not arrived yet" [])


port task : Task x ()
port task =
    sequence
        [ WebAPI.MathTest.tests
        , WebAPI.NumberTest.tests
        ]
    `andThen`
    (send tests.address << suite "Browser tests")

