# elm-web-api

The purpose of this package is to expose various standard web APIs to Elm,
or document where they are already exposed.

By "web APIs" I basically mean the kind of things that are listed on
Mozilla's various Web APIs pages, e.g.

* https://developer.mozilla.org/en-US/docs/Web/API
* https://developer.mozilla.org/en-US/docs/WebAPI
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference

Essentially, they are various facilities available in a Javascript web
environment.

In order for Elm to use such facilities, it is necessary to write "native"
code.

* If the Elm code for a Web API already exists, I document it below.
* If it does not already exist, then I have either:
    * implemented it;
    * indicated why it should not be implemented;
    * or, put it on my TODO list.

The implementations provided here are intentionally simplistic. The idea is to
do as little as possible to make the API available in Elm -- any additional
logic or convenience can be supplied by other packages on top of this.


## WebAPI.Date

Generally speaking, dates are dealt with by the
[`Date` module](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Date)
in elm-lang/core.

TODO: Check if anything is missing.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date).


## WebAPI.Global

See the Mozilla documentation for
[function properties](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects#Function_properties).

*   `eval`
    Not implemented, since it is an abomination.

*   `isFinite`
    In elm-lang/core, as 
    [`Basics.isInfinite`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#isInfinite)
    (presumably with the sense reversed).

*   `isNan`
    In elm-lang/core, as
    [`Basics.isNan`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#isNaN)

*   `parseFloat`
    In elm-lang/core, as
    [`String.toFloat`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/String#toFloat)

*   `parseInt`
    In elm-lang/core, as
    [`String.toInt`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/String#toInt)

*   `decodeURI`
    Not implemented, since you will generally want `decodeURIComponent` instead.

*   `decodeURIComponent`
    In evancz/elm-http, as
    [`Http.uriDecode`](http://package.elm-lang.org/packages/evancz/elm-http/2.0.0/Http#uriDecode)

*   `encodeURI`
    Not implemented, since you will generally want `encodeURIComponent` instead.

*   `encodeURIComponent`
    In evancz/elm-http, as 
    [`Http.uriEncode`](http://package.elm-lang.org/packages/evancz/elm-http/2.0.0/Http#uriEncode)


## WebAPI.Intl

TODO.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl).


## WebAPI.JSON

Generally speaking, JSON is handled by the
[`Json.Decode`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Json-Decode) and
[`Json.Encode`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Json-Encode)
modules in elm-lang/core.

TODO: Check if anything is missing.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON).


## WebAPI.Math

See the Mozilla documentation for the
[Math object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math).
Note that things marked "experimental" there have been omitted here.

### Constants

*   `E`
    In elm-lang/core, as
    [`Basics.e`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#e)

*   `ln2 : Float`

    Natural logarithm of 2, approximately 0.693.

*   `ln10 : Float`

    Natural logarithm of 2, approximately 2.303.

*   `log2e : Float`

    Base 2 logarithm of E, approximately 1.443

*   `log10e : Float`

    Base 10 logarithm of E, approximately 0.434

*   `PI`
    In elm-lang/core, as
    [`Basics.pi`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#pi)

*   `sqrt1_2 : Float`

    Square root of 1/2; equivalently, 1 over the square root of 2, approximately 0.707.

*   `sqrt2 : Float`

    Square root of 2, approximately 1.414.

### Functions

*   `abs`
    In elm-lang/core, as
    [`Basics.abs`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#abs)

*   `acos`
    In elm-lang/core, as
    [`Basics.acos`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#acos)

*   `asin`
    In elm-lang/core, as
    [`Basics.asin`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#asin)

*   `atan`
    In elm-lang/core, as
    [`Basics.atan`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#atan)

*   `atan2`
    In elm-lang/core, as
    [`Basics.atan2`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#atan2)

*   `ceil`
    In elm-lang/core, as
    [`Basics.ceiling`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#ceiling)

*   `cos`
    In elm-lang/core, as
    [`Basics.cos`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#cos)

*   `exp : number -> Float`

    Returns E to the power of x, where x is the argument, and E is Euler's
    constant (2.718…), the base of the natural logarithm.

*   `floor`
    In elm-lang/core, as
    [`Basics.floor`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#floor)


*   `log : number -> Float`

    Returns the natural logarithm (log e, also ln) of a number.

*   `max`
    In elm-lang/core, as
    [`List.maximum`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/List#maximum)

*   `min`
    In elm-lang/core, as
    [`List.minimum`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/List#minimum)

*   `pow`
    In elm-lang/core, as
    [`Basics.(^)`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#^)

*   `random : Task x Float`

    Returns a pseudo-random number between 0 and 1.

    Note that there is a more sophisticated implementation of 
    [`Random`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Random)
    in elm-lang/core. However, this may sometimes be useful if you're in a `Task`
    context anyway.

*   `round`
    In elm-lang/core, as
    [`Basics.round`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#round)

*   `sin`
    In elm-lang/core, as
    [`Basics.sin`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#sin)

*   `sqrt`
    In elm-lang/core, as
    [`Basics.sqrt`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#sqrt)

*   `tan`
    In elm-lang/core, as
    [`Basics.tan`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#tan)


## WebAPI.Number

See the Mozilla documentation for the
[Number object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number).
Note that things marked "experimental" there have been omitted here.

### Constants

*   `maxValue : Float`

    The largest positive representable number.

*   `minValue : Float`

    The smallest positive representable number - that is, the positive number
    closest to zero (without actually being zero).

*   `nan : Float`

    Special "not a number" value.

*   `negativeInfinity : Float`

    Special value representing negative infinity; returned on overflow.

*   `positiveInfinity : Float`

    Special value representing infinity; returned on overflow.

### Functions

*   `toExponential : number -> String`

    A string representing the provided number in exponential notation.

*   `toExponentialDigits : Int -> number -> Result String String`

    Either a string representing the second parameter in exponential notation,
    with the requested number of digits after the decimal point (first parameter),
    or an error. An error should not occur if the requested number of digits is
    between 0 and 20.

*   `toFixed : number -> String`

    A string representing the provided number in fixed-point notation.

*   `toFixedDigits : Int -> number -> Result String String`

    Either a string representing the second parameter in fixed-point notation,
    with the requested number of digits after the decimal point (first parameter),
    or an error. An error should not occur if the requested number of digits is
    between 0 and 20.

*   `toLocaleString`

    Not implemented for the moment, since localization requires some thought.

*   `toPrecisionDigits : Int -> number -> Result String String`

    Either a string representing the second parameter in fixed-point or
    exponential notation, rounded to the requested number of significant digits
    (first parameter), or an error. An error should not occur if the requested
    number of digits is between 0 and 20.

*   `toStringUsingBase : Int -> number -> Result String String`

    Either a string representing the second parameter using the requested base
    (first parameter), or an error. An error should not occur if the requested base
    is between 2 and 36.


## WebAPI.RegExp

Generally speaking, regular expressions are handled by the
[`Regex` module](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Regex)
in elm-lang/core.

TODO: Check if anything is missing.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).


## WebAPI.Storage

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Storage)

*   `localStorage : Storage`

    The browser's `localStorage` object.

*   `sessionStorage : Storage`

    The browser's `sessionStorage` object.

*   `length : Storage -> Task x Int`

    A task which, when executed, determines the number of items stored in the
    `Storage` object.

*   `key : Storage -> Int -> Task x (Maybe String)`

    A task which, when executed, determines the name of the key at the given
    index (zero-based).

*   `getItem : Storage -> String -> Task x (Maybe String)`

    A task which, when executed, gets the value at the given key.

*   `setItem : Storage -> String -> String -> Task String ()`

    A task which, when executed, sets the value (third parameter)
    at the given key (second parameter), or fails with an error message.

*   `removeItem : Storage -> String -> Task x ()`

    A task which, when executed, removes the item with the given key.

*   `clear : Storage -> Task x ()`
    
    A task which, when executed, removes all items.


## WebAPI.Screen

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Screen).

```elm
type alias Screen =
    { availTop: Int
    , availLeft: Int
    , availHeight: Int
    , availWidth: Int
    , colorDepth: Int
    , pixelDepth: Int
    , height: Int
    , width: Int
    }
``` 

*   `screen : Task x Screen`

    The browser's `window.screen` object.

    This is a `Task` because in multi-monitor setups, the result depends on which screen
    the browser window is in. So, it is not necessarily a constant.


## WebAPI.String

Generally speaking, strings are dealt with by the
[`String` module](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/String)
in elm-lang/core. 

TODO: Check if anything is missing.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String).


## WebAPI.Window

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Window).

Since the browser's `window` object has so many facilities attached, I've typically split
them up into individual modules -- see below for the cross-references.

TODO: Finish going through the `window` API.

*   `history`
    See [TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest)

*   `innerHeight`, `innerWidth`
    See [`Window.dimensions`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Window#dimensions)
    in elm-lang/core

*   `localStorage`
    See `WebAPI.Storage.localStorage`

*   `location`
    See [TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest)

*   `screen`
    See `WebAPI.Screen.screen`

*   `sessionStorage`
    See `WebAPI.Storage.sessionStorage`


