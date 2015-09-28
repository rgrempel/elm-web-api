module Browser.MathTest where

import ElmTest.Test exposing (..)
import ElmTest.Assertion exposing (..)
import Task exposing (Task, sequence, succeed)

import Browser.Math


within : Float -> Float -> Float -> Assertion
within tolerance value1 value2 =
    assert <|
        abs (value1 - value2) < tolerance


within001 : Float -> Float -> Assertion
within001 = within 0.001


random : Task x Test
random =
    Browser.Math.random |>
        Task.map (\r ->
            test "random" <|
                assert <|
                    (r >= 0 && r <= 1)
        )


tests : Task x Test
tests =
    Task.map (suite "Browser.Math") <|
        sequence <|
            List.map succeed
                [ test "ln2" <| within001 Browser.Math.ln2 0.693
                , test "ln10" <| within001 Browser.Math.ln10 2.303
                , test "log2e" <| within001 Browser.Math.log2e 1.443
                , test "log10e" <| within001 Browser.Math.log10e 0.434
                , test "sqrt1_2" <| within001 Browser.Math.sqrt1_2 0.707
                , test "sqrt2" <| within001 Browser.Math.sqrt2 1.414
                , test "exp" <| within001 (Browser.Math.exp 2) (e ^ 2)
                , test "log" <| within001 (Browser.Math.log 27) (logBase e 27)
                ]
            ++
            [ random
            ]
