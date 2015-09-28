module Browser.Number
    ( maxValue, minValue, nan, negativeInfinity, positiveInfinity
    , toExponential, toExponentialDigits
    , toFixed, toFixedDigits
    , toPrecisionDigits
    , toStringUsingBase
    ) where


{-| Various facilities from the browser's `Number` object that are not
otherwise available in Elm.

See the [https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number).

## Constants

@docs maxValue, minValue, nan, negativeInfinity, positiveInfinity

## Functions

@docs toExponential, toExponentialDigits
-}


import Result exposing (Result)
import Native.Browser.Number


{-| The largest positive representable number. -}
maxValue : Float
maxValue = Native.Browser.Number.maxValue


{-| The smallest positive representable number - that is, the positive number
closest to zero (without actually being zero).
-}
minValue : Float
minValue = Native.Browser.Number.minValue


{-| Special "not a number" value. -}
nan : Float
nan = Native.Browser.Number.nan


{-| Special value representing negative infinity; returned on overflow. -}
negativeInfinity : Float
negativeInfinity = Native.Browser.Number.negativeInfinity


{-| Special value representing infinity; returned on overflow. -}
positiveInfinity : Float
positiveInfinity = Native.Browser.Number.positiveInfinity


{-| A string representing the provided number in exponential notation. -}
toExponential : number -> String
toExponential = Native.Browser.Number.toExponential


{-| Either a string representing the second parameter in exponential notation,
with the requested number of digits after the decimal point (first parameter),
or an error. An error should not occur if the requested number of digits is
between 0 and 20.
-}
toExponentialDigits : Int -> number -> Result String String
toExponentialDigits = Native.Browser.Number.toExponentialDigits


{-| A string representing the provided number in fixed-point notation. -}
toFixed : number -> String
toFixed = Native.Browser.Number.toFixed


{-| Either a string representing the second parameter in fixed-point notation,
with the requested number of digits after the decimal point (first parameter),
or an error. An error should not occur if the requested number of digits is
between 0 and 20.
-}
toFixedDigits : Int -> number -> Result String String
toFixedDigits = Native.Browser.Number.toFixedDigits


{-| Either a string representing the second parameter in fixed-point or
exponential notation, with the requested number of significant digits (first
parameter), or an error. An error should not occur if the requested number of
digits is between 0 and 20.
-}
toPrecisionDigits : Int -> number -> Result String String
toPrecisionDigits = Native.Browser.Number.toPrecisionDigits


{-| Either a string representing the second parameter using the requested base
(first parameter), or an error. An error should not occur if the requested base
is between 2 and 36.
-}
toStringUsingBase : Int -> number -> Result String String
toStringUsingBase = Native.Browser.Number.toStringUsingBase
