# elm-web-api

The purpose of this package is to expose various standard web APIs to Elm,
or document where they are already exposed.

By "web APIs" I basically mean the kind of things that are listed on
Mozilla's various Web APIs pages, e.g.

* https://developer.mozilla.org/en-US/docs/Web/API
* https://developer.mozilla.org/en-US/docs/WebAPI
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference

Essentially, they are various facilities available in a Javascript web
environment. In order for Elm to use such facilities, it is necessary to write
"native" code.

* If the Elm code for a Web API already exists, I document it below.
* If it does not already exist, then I have either:
    * implemented it;
    * indicated why it should not be implemented;
    * or, put it on my TODO list.

The implementations provided here are intentionally simplistic. The idea is to
do as little as possible to make the API available in Elm -- any additional
logic or convenience can be supplied by other packages on top of this.

One question I haven't entirely settled on is how to account for the fact that
some of these facilities might not always be available. For the moment, I'm
applying the following principles:

* For the moment, at least, I'm not implementing things at all unless they are
  common to the 'evergreen' browsers.

* Where the Javascript can throw exceptions in the normal course of events,
  I'm accounting for that in the API (i.e. via using `Result`, `Maybe` or
  `Task` to wrap the return value, as appropriate).

* In principle, I could use the same mechanism to deal with whole facilities
  that aren't present (e.g. returning a `Maybe Storage` in `WebAPI.Storage`
  so that I can return `Nothing` if it's not present). However, that would
  add some complexity for the client for possibly little gain.

* Eventually, I'll set up testing via Travis and SauceLabs, so that I can
  precisely define which browsers are supported. Then, if there are specific
  facilities that are missing from some browsers I'd like to support, I can do
  something fancy to account for that.

* For the moment, I'm not thinking too hard about supporting node.js. That's a
  somewhat larger issue for Elm (it requires some shimming even to get
  elm-lang/core to work). Furthermore, it might make sense to have a separate
  package to wrap node.js-oriented APIs (and provide appropriate shims), even
  if there is some overlap.


## Contents

* [WebAPI.Location](#webapilocation)
* [WebAPI.Math](#webapimath)
* [WebAPI.Number](#webapinumber)
* [WebAPI.Screen](#webapiscreen)
* [WebAPI.Storage](#webapistorage)
* [WebAPI.Window](#webapiwindow)

## WebAPI.Date

Generally speaking, dates are dealt with by the
[`Date` module](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Date)
in elm-lang/core.

TODO: Check if anything is missing.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date).


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


## WebAPI.Location

See the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Location).

Note that there is a `Signal`-oriented library for location-related things at
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).

```elm
module WebAPI.Location where

type alias Location =
    { href: String
    , protocol: String
    , host: String
    , hostname: String
    , port': String
    , pathname: String
    , search: String
    , hash: String
    , origin: String
    }

{-| The browser's `window.location` object. -}
location : Task x Location

{-| Reloads the page from the current URL. The parameter controls whether to
force the browser to reload from the server (`True`), or allow the use of the
cache (`False`).
-}
reload : Bool -> Task String ()
```

***See also***

**`assign`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `setPath` from
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).

**`replace`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `replacePath` from
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).


## WebAPI.Math

See the Mozilla documentation for the
[Math object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math).
Note that things marked "experimental" there have been omitted here.

```elm
module WebAPI.Math where

{-| Returns E to the power of x, where x is the argument, and E is Euler's
constant (2.718…), the base of the natural logarithm.
-}
exp : number -> Float

{-| Natural logarithm of 2, approximately 0.693. -}
ln2 : Float

{-| Natural logarithm of 2, approximately 2.303. -}
ln10 : Float

{-| Returns the natural logarithm (log e, also ln) of a number. -}
log : number -> Float

{-| Base 2 logarithm of E, approximately 1.443. -}
log2e : Float

{-| Base 10 logarithm of E, approximately 0.434. -}
log10e : Float

{-| Returns a pseudo-random number between 0 and 1.

Note that there is a more sophisticated implementation of `Random` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).
However, this may sometimes be useful if you're in a `Task` context anyway.
-}
random : Task x Float

{-| Square root of 1/2; equivalently, 1 over the square root of 2,
approximately 0.707.
-}
sqrt1_2 : Float

{-| Square root of 2, approximately 1.414. -}
sqrt2 : Float
```

***See also***

**`abs`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.abs` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`acos`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.acos` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`asin`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.asin` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`atan`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.atan` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`atan2`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.atan2` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`ceil`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.ceiling` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`cos`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.cos` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`E`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.e` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`floor`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.floor` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`max`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `List.maximum` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`min`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `List.minimum` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`PI`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.pi` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`pow`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.(^)` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`round`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.round` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`sin`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.sin` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`sqrt`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.sqrt` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`tan`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.tan` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).


## WebAPI.Number

See the Mozilla documentation for the
[Number object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number).
Note that things marked "experimental" there have been omitted here.

```elm
module WebAPI.Number where

{-| The largest positive representable number. -}
maxValue : Float

{-| The smallest positive representable number - that is, the positive number
closest to zero (without actually being zero).
-}
minValue : Float

{-| Special "not a number" value. -}
nan : Float

{-| Special value representing negative infinity; returned on overflow. -}
negativeInfinity : Float

{-| Special value representing infinity; returned on overflow. -}
positiveInfinity : Float

{-| A string representing the provided number in exponential notation. -}
toExponential : number -> String

{-| Either a string representing the second parameter in exponential notation,
with the requested number of digits after the decimal point (first parameter),
or an error. An error should not occur if the requested number of digits is
between 0 and 20.
-}
toExponentialDigits : Int -> number -> Result String String

{-| A string representing the second parameter in exponential notation,
with the requested number of digits after the decimal point (first parameter).
The number of digits will be limited to between 0 and 20.
-}
safeExponentialDigits : Int -> number -> String

{-| A string representing the provided number in fixed-point notation. -}
toFixed : number -> String

{-| Either a string representing the second parameter in fixed-point notation,
with the requested number of digits after the decimal point (first parameter),
or an error. An error should not occur if the requested number of digits is
between 0 and 20.
-}
toFixedDigits : Int -> number -> Result String String

{-| A string representing the second parameter in fixed-point notation,
with the requested number of digits after the decimal point (first parameter).
The number of digits will be limited to between 0 and 20.
-}
safeFixedDigits : Int -> number -> String

{-| Either a string representing the second parameter in fixed-point or
exponential notation, rounded to the requested number of significant digits
(first parameter), or an error. An error should not occur if the requested
number of digits is between 0 and 20.
-}
toPrecisionDigits : Int -> number -> Result String String

{-| A string representing the second parameter in fixed-point or exponential
notation, with the requested number of significant digits (first parameter).
The number of digits will be limited to between 1 and 20.
-}
safePrecisionDigits : Int -> number -> String

{-| Either a string representing the second parameter using the requested base
(first parameter), or an error. An error should not occur if the requested base
is between 2 and 36.
-}
toStringUsingBase : Int -> number -> Result String String

{-| A string representing the second parameter, using the requested base
(first parameter).  The requested base will be limited to between 2 and 36.
-}
safeStringUsingBase : Int -> number -> String

```

***See also***

**`toLocaleString`**

&nbsp; &nbsp; &nbsp; &nbsp;
Not implemented for the moment, since localization requires some thought.


## WebAPI.RegExp

Generally speaking, regular expressions are handled by the
[`Regex` module](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Regex)
in elm-lang/core.

TODO: Check if anything is missing.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).


## WebAPI.Screen

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Screen).

```elm
module WebAPI.Screen where

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

{-| The browser's `window.screen` object.

This is a `Task` because, in multi-monitor setups, the result depends on which
screen the browser window is in. So, it is not necessarily a constant.
-}
screen : Task x Screen

{-| A tuple of `(window.screenX, window.screenY)`.

The first value is the horizontal distance, in CSS pixels, of the left border
of the user's browser from the left side of the screen.

The second value is the vertical distance, in CSS pixels, of the top border of
the user's browser from the top edge of the screen.
-}
screenXY : Task x (Int, Int)
```


## WebAPI.Storage

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Storage)

Note that we're essentially assuming that `window.localStorage` and
`window.sessionStorage` are, in fact, available. We could account for them
possibly not being available by using a `Maybe` type.

```elm
module WebAPI.Storage where

{-| The browser's `localStorage` object. -}
localStorage : Storage

{-| The browser's `sessionStorage` object. -}
sessionStorage : Storage

{-| A task which, when executed, determines the number of items stored in the
`Storage` object.
-}
length : Storage -> Task x Int

{-| A task which, when executed, determines the name of the key at the given
index (zero-based).
-}
key : Storage -> Int -> Task x (Maybe String)

{-| A task which, when executed, gets the value at the given key. -}
getItem : Storage -> String -> Task x (Maybe String)

{-| A task which, when executed, sets the value (third parameter) at the given
key (second parameter), or fails with an error message. -}
setItem : Storage -> String -> String -> Task String ()`

{-| A task which, when executed, removes the item with the given key. -}
removeItem : Storage -> String -> Task x ()

{-| A task which, when executed, removes all items. -}
clear : Storage -> Task x ()
```


## WebAPI.String

Generally speaking, strings are dealt with by the
[`String` module](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/String)
in elm-lang/core.

TODO: Check if anything is missing.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String).


## WebAPI.Window

See Mozilla documentation for the
[`Window` object](https://developer.mozilla.org/en-US/docs/Web/API/Window),
and for
[function properties](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects#Function_properties).

Since the browser's `window` object has so many facilities attached, I've typically split
them up into individual modules -- see below for the cross-references.

TODO: Finish going through the `window` API.

```elm
module WebAPI.Window where

{-| The browser's `window.alert()` function. -}
alert : String -> Task x ()

{-| The browser's `window.confirm()` function.

The task will succeed if the user confirms, and fail if the user cancels.
-}
confirm : String -> Task () ()

{-| The browser's `window.prompt()` function.

The first parameter is a message, and the second parameter is a default
response.

The task will succeed with the user's response, or fail if the user cancels or
enters blank text.
-}
prompt : String -> String -> Task () String
```

***See also***

**`decodeURI`**

&nbsp; &nbsp; &nbsp; &nbsp;
Not implemented, since you will generally want `decodeURIComponent` instead.

**`decodeURIComponent`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Http.uriDecode` from
[evancz/elm-http](http://package.elm-lang.org/packages/evancz/elm-http/latest).

**`encodeURI`**

&nbsp; &nbsp; &nbsp; &nbsp;
Not implemented, since you will generally want `encodeURIComponent` instead.

**`encodeURIComponent`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Http.uriEncode` from
[evancz/elm-http](http://package.elm-lang.org/packages/evancz/elm-http/latest).

**`eval`**

&nbsp; &nbsp; &nbsp; &nbsp;
Not implemented, since it is an abomination.

**`history`**

&nbsp; &nbsp; &nbsp; &nbsp;
See [TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest)

**`innerHeight`, `innerWidth`**

&nbsp; &nbsp; &nbsp; &nbsp;
See `Window.dimensions` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`isFinite`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `not Basics.isInfinite` from
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest)
(i.e. with the sense reversed).

**`isNan`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Basics.isNan` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`localStorage`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use [`WebAPI.Storage.localStorage`](#webapistorage)

**`location`**

&nbsp; &nbsp; &nbsp; &nbsp;
For a `Signal`-oriented approach to things you might do with `window.location`, see
[TheSeamau5/elm-history](http://package.elm-lang.org/packages/TheSeamau5/elm-history/latest).
For some additional `Task`-oriented approaches, see
[`WebAPI.Location`](#webapilocation).

**`parseFloat`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `String.toFloat` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`parseInt`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `String.toInt` in
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest).

**`setInterval`**

&nbsp; &nbsp; &nbsp; &nbsp;
Consider `Time.fps` (or its variants) from
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest),
or `AnimationFrame.frame` (or its variants) from
[jwmerrill/elm-animation-frame](http://package.elm-lang.org/packages/jwmerrill/elm-animation-frame/latest),
or its variants, or `Effects.tick` from
[evancz/elm-effects](http://package.elm-lang.org/packages/evancz/elm-effects/latest).

**`setTimeout`**

&nbsp; &nbsp; &nbsp; &nbsp;
Use `Task.sleep` from
[elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/latest),
and then apply an `andThen` to do something after sleeping.

**`scroll`, `scrollBy`, `scrollTo`, `scrollX`, `scrollY`**

&nbsp; &nbsp; &nbsp; &nbsp;
There are a few puzzles about how to best adapt these for Elm, so I'm not sure
a simplistic approach would be best -- a module that thought through scrolling
in an Elm context would probably be better.

**`screen`**

&nbsp; &nbsp; &nbsp; &nbsp;
See [`WebAPI.Screen.screen`](#webapiscreen).

**`screenX`, `screenY`**

&nbsp; &nbsp; &nbsp; &nbsp;
See [`WebAPI.Screen.screenXY`](#webapiscreen).

**`sessionStorage`**

&nbsp; &nbsp; &nbsp; &nbsp;
See [`WebAPI.Storage.sessionStorage`](#webapistorage)


