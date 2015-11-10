module Tests where

import Signal exposing (Signal, Mailbox, mailbox, constant, send)
import Task exposing (Task, andThen, sequence, onError)
import ElmTest.Test exposing (Test, suite)
import ElmTest.Assertion exposing (assert)

import TestMailbox

import WebAPI.MathTest
import WebAPI.NumberTest
import WebAPI.StorageTest
import WebAPI.ScreenTest
import WebAPI.LocationTest
import WebAPI.DateTest
import WebAPI.AnimationFrameTest
import WebAPI.CookieTest
import WebAPI.DocumentTest


test : Bool -> Task x Test
test disableStorage =
    let
        allTests =
            Task.map (suite "WebAPI tests") <|
                sequence tests

        tests =
            if disableStorage
                then testsWithStorageDisabled
                else defaultTests

        defaultTests =
            [ WebAPI.DocumentTest.tests
            , WebAPI.MathTest.tests
            , WebAPI.NumberTest.tests
            , WebAPI.StorageTest.tests False
            , WebAPI.ScreenTest.tests
            , WebAPI.LocationTest.tests
            , WebAPI.DateTest.tests
            , WebAPI.AnimationFrameTest.tests
            , WebAPI.CookieTest.tests
            ]

        testsWithStorageDisabled =
            [ WebAPI.StorageTest.tests True
            ]

    in
        onError allTests <|
            always <|
                Task.succeed <|
                    ElmTest.Test.test "Some task failed" <|
                        assert False


task : Bool -> Task x ()
task disableStorage =
    test disableStorage 
        `andThen` send tests.address


tests : Mailbox Test
tests = TestMailbox.tests
