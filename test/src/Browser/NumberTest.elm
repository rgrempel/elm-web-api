module Browser.NumberTest where

import ElmTest.Test exposing (..)
import ElmTest.Assertion exposing (..)
import Task exposing (Task, sequence, succeed)
import Result exposing (Result(..))

import Browser.Number


within : Float -> Float -> Float -> Assertion
within tolerance value1 value2 =
    assert <|
        abs (value1 - value2) < tolerance


within001 : Float -> Float -> Assertion
within001 = within 0.001


isErr : Result a b -> Bool
isErr result =
    case result of
        Ok _ -> False
        Err _ -> True


tests : Task x Test
tests =
    Task.map (suite "Browser.Number") <|
        sequence <|
            List.map succeed
                [ test "maxValue" <| assert <| Browser.Number.maxValue > 1000
                , test "minValue" <| within001 Browser.Number.minValue 0
                , test "nan" <| assert <| isNaN Browser.Number.nan
                , test "negativeInfinity" <| assert <| isInfinite Browser.Number.negativeInfinity
                , test "positiveInfinity" <| assert <| isInfinite Browser.Number.positiveInfinity
                , test "toExponential" <| assertEqual (Browser.Number.toExponential 200) "2e+2"
                , test "toExponentialDigits success" <| assertEqual (Browser.Number.toExponentialDigits 1 200.0) (Ok "2.0e+2")
                , test "toExponentialDigits failure" <| assert <| isErr (Browser.Number.toExponentialDigits -10 200)
                , test "toExponentialDigits integer" <| assertEqual (Browser.Number.toExponentialDigits 1 200) (Ok "2.0e+2")
                , test "toFixed" <| assertEqual (Browser.Number.toFixed 200.1) "200"
                , test "toFixedDigits success" <| assertEqual (Browser.Number.toFixedDigits 2 200.1) (Ok "200.10")
                , test "toFixedDigits failure" <| assert <| isErr (Browser.Number.toFixedDigits -10 200)
                , test "toFixedDigits integer" <| assertEqual (Browser.Number.toFixedDigits 2 200) (Ok "200.00")
                , test "toPrecisionDigits success" <| assertEqual (Browser.Number.toPrecisionDigits 5 200.1) (Ok "200.10")
                , test "toPrecisionDigits failure" <| assert <| isErr (Browser.Number.toPrecisionDigits -10 200)
                , test "toPrecisionDigits integer" <| assertEqual (Browser.Number.toPrecisionDigits 2 223) (Ok "2.2e+2")
                , test "toStringUsingBase success" <| assertEqual (Browser.Number.toStringUsingBase 16 32.0) (Ok "20")
                , test "toStringUsingBase failure" <| assert <| isErr (Browser.Number.toStringUsingBase -10 200)
                , test "toStringUsingBase integer" <| assertEqual (Browser.Number.toStringUsingBase 16 32) (Ok "20")
                ]
