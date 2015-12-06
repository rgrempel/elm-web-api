module Tests where

import Signal exposing (Signal, Mailbox, mailbox, constant, send)
import Task exposing (Task, andThen, sequence, onError)
import ElmTest.Test exposing (Test, suite)
import ElmTest.Assertion exposing (assert)

import TestMailbox
import Variant exposing (Variant(..))

import WebAPI.MathTest
import WebAPI.NumberTest
import WebAPI.StorageTest
import WebAPI.ScreenTest
import WebAPI.LocationTest
import WebAPI.DateTest
import WebAPI.AnimationFrameTest
import WebAPI.CookieTest
import WebAPI.DocumentTest
import WebAPI.WindowTest
import WebAPI.FunctionTest
import WebAPI.EventTest


test : Variant -> Task x Test
test variant =
    let
        allTests =
            Task.map (suite "WebAPI tests") <|
                sequence tests

        tests =
            case variant of
                AllTests ->
                    defaultTests
                
                DisableStorage ->
                    testsWithStorageDisabled
                
                DisableRequestAnimationFrame ->
                    testsWithoutRequestAnimationFrame

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
            , WebAPI.WindowTest.tests
            , WebAPI.FunctionTest.tests
            , WebAPI.EventTest.tests
            ]

        testsWithStorageDisabled =
            [ WebAPI.StorageTest.tests True
            ]
        
        testsWithoutRequestAnimationFrame =
            [ WebAPI.AnimationFrameTest.tests
            ]

    in
        onError allTests <|
            always <|
                Task.succeed <|
                    ElmTest.Test.test "Some task failed" <|
                        assert False


task : Variant -> Task x ()
task variant =
    test variant 
        `andThen` send tests.address


tests : Mailbox Test
tests = TestMailbox.tests
