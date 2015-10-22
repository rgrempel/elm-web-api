module WebAPI.DateTest where

import ElmTest.Test exposing (..)
import ElmTest.Assertion exposing (..)
import Task exposing (Task, sequence, succeed, andThen)

import WebAPI.Date exposing (..)
import Date
import Time


testCurrent : Task x Test
testCurrent =
    current |>
        Task.map (\c ->
            test "current" <|
                assert <|
                    (Date.year c) > 2014
        )


testNow : Task x Test
testNow =
    now |>
        Task.map (\n ->
            test "now" <|
                assert <|
                    n > 1445463720748
        )


testFromParts : Test
testFromParts =
    let
        date =
            fromParts (Parts 2015 1 1 1 1 1 1)

        tuple =
            ( Date.year date
            , Date.month date
            , Date.day date
            , Date.hour date
            , Date.minute date
            , Date.second date
            , Date.millisecond date
            )

    in
        test "fromParts" <|
            assertEqual tuple
                (2015, Date.Feb, 1, 1, 1, 1, 1)


testUtc : Test
testUtc =
    let
        time =
            utc (Parts 2015 1 1 1 1 1 1)

    in
        test "utc" <|
            assert (abs (time - 1422752461001) < (12 * Time.hour))


testTimezoneOffset : Test
testTimezoneOffset =
    let
        date =
            fromParts (Parts 2015 1 1 1 1 1 1)

    in
        test "timezoneOffset" <|
            assert <|
                (abs (timezoneOffset date)) < (12 * Time.hour)


tests : Task () Test
tests =
    Task.map (suite "WebAPI.DateTest") <|
        sequence <|
            [ testCurrent
            , testNow
            ]
            ++
            List.map Task.succeed
                [ testFromParts
                , testUtc
                , testTimezoneOffset
                ]

