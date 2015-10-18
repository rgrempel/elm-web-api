module Tests where

import Signal exposing (Signal, Mailbox, mailbox, constant, send)
import Task exposing (Task, andThen, sequence)
import ElmTest.Test exposing (Test, suite)

import WebAPI.MathTest
import WebAPI.NumberTest
import WebAPI.StorageTest
import WebAPI.ScreenTest
import WebAPI.LocationTest


test : Task () Test
test =
    Task.map (suite "WebAPI tests") <|
        sequence
            [ WebAPI.MathTest.tests
            , WebAPI.NumberTest.tests
            , WebAPI.StorageTest.tests
            , WebAPI.ScreenTest.tests
            , WebAPI.LocationTest.tests
            ]


task : Task () ()
task =
    test `andThen` send tests.address


tests : Mailbox Test
tests =
    mailbox (suite "Tests have not arrived yet" [])


