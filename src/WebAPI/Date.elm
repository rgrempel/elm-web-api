module WebAPI.Date
    ( current, now
    , Parts, fromParts
    , utc, timezoneOffset
    ) where


{-| The browser's `Date` type.

See the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date).

# Getting the current date or time

@docs current, now

# Constructors

For the browser's `new Date(String)`, use `Date.fromString` from
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

@docs Parts, fromParts, utc

@docs timezoneOffset
-}

import Date exposing (Date)
import Time exposing (Time)
import Task exposing (Task)

import Native.WebAPI.Date


{-| Get the current date, via the browser's `new Date()` -}
current : Task x Date
current = Native.WebAPI.Date.current


{-| Get the current time, via the browser's `Date.now()` -}
now : Task x Time
now = Native.WebAPI.Date.now


{-| The parts of a date, as a record. Note that, as in Javascript,
the month is 0-based, with January = 0.
-}
type alias Parts =
    { year : Int
    , month : Int
    , day : Int
    , hour : Int
    , minutes : Int
    , seconds : Int
    , milliseconds : Int
    }


{-| Construct a `Date` from the provided values, via the
browser's `new Date(...)`
-}
fromParts : Parts -> Date
fromParts = Native.WebAPI.Date.fromParts


{-| Construct a `Time` from the provided UTC values, via the browser's
`Date.UTC()`.

TODO: Consider whether the implicitly applied UTC offset can be considered a
constant.
-}
utc : Parts -> Time
utc = Native.WebAPI.Date.utc


{-| The difference between UTC and local time. Note that this is in units of
`Time`, rather than "minutes" as in Javascript.

TODO: Consider whether this is really a constant ... technically, it may need
to be a `Task`, since in theory the `timezoneOffset` can change.
-}
timezoneOffset : Date -> Time
timezoneOffset date =
    (timezoneOffsetInMinutes date) * Time.minute


timezoneOffsetInMinutes : Date -> Time
timezoneOffsetInMinutes = Native.WebAPI.Date.timezoneOffsetInMinutes

