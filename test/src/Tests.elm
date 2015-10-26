module Tests where

import Signal exposing (Signal, Mailbox, mailbox, constant, send)
import Task exposing (Task, andThen, sequence)
import ElmTest.Test exposing (Test, suite)

import TestMailbox

import WebAPI.MathTest
import WebAPI.NumberTest
import WebAPI.StorageTest
import WebAPI.ScreenTest
import WebAPI.LocationTest
import WebAPI.DateTest
import WebAPI.AnimationFrameTest


test : Task () Test
test =
    Task.map (suite "WebAPI tests") <|
        sequence
            [ WebAPI.MathTest.tests
            , WebAPI.NumberTest.tests
            , WebAPI.StorageTest.tests
            , WebAPI.ScreenTest.tests
            , WebAPI.LocationTest.tests
            , WebAPI.DateTest.tests
            , WebAPI.AnimationFrameTest.tests
            ]


task : Task () ()
task =
    test `andThen` send tests.address


tests : Mailbox Test
tests = TestMailbox.tests
