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

<dl>

<dt>`eval`</dt>
<dd>Not implemented, since it is an abomination.</dd>

<dt>`isFinite`</dt>
<dd>In elm-lang/core, as 
[`Basics.isInfinite`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#isInfinite)
(presumably with the sense reversed).</dd>

<dt>`isNan`</dt>
<dd>In elm-lang/core, as
[`Basics.isNan`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#isNaN)
</dd>

<dt>`parseFloat`</dt>
<dd>In elm-lang/core, as
[`String.toFloat`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/String#toFloat)
</dd>

<dt>`parseInt`</dt>
<dd>In elm-lang/core, as
[`String.toInt`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/String#toInt)
</dd>

<dt>`decodeURI`</dt>
<dd>Not implemented, since you will generally want `decodeURIComponent` instead.</dd>

<dt>`decodeURIComponent`</dt>
<dd>In evancz/elm-http, as
[`Http.uriDecode`](http://package.elm-lang.org/packages/evancz/elm-http/2.0.0/Http#uriDecode)
</dd>

<dt>`encodeURI`</dt>
<dd>Not implemented, since you will generally want `encodeURIComponent` instead.</dd>

<dt>`encodeURIComponent`</dt>
<dd>In evancz/elm-http, as 
[`Http.uriEncode`](http://package.elm-lang.org/packages/evancz/elm-http/2.0.0/Http#uriEncode)
</dd>

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

<dl>

<dt>`E`</dt>
<dd>In elm-lang/core, as
[`Basics.e`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#e)
</dd>

<dt>`ln2 : Float`</dt>
<dd>Natural logarithm of 2, approximately 0.693.</dd>

<dt>`ln10 : Float`</dt>
<dd>Natural logarithm of 2, approximately 2.303.</dd>

<dt>`log2e : Float`</dt>
<dd>Base 2 logarithm of E, approximately 1.443</dd>

<dt>`log10e : Float`</dt>
<dd>Base 10 logarithm of E, approximately 0.434</dd>

<dt>`PI`</dt>
<dd>In elm-lang/core, as
[`Basics.pi`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#pi)
</dd>

<dt>`sqrt1_2 : Float`</dt>
<dd>Square root of 1/2; equivalently, 1 over the square root of 2, approximately 0.707.</dd>

<dt>`sqrt2 : Float`</dd>
<dd>Square root of 2, approximately 1.414.</dd>

</dl>

### Functions

<dl>

<dt>`abs`</dt>
<dd>In elm-lang/core, as
[`Basics.abs`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#abs)
</dd>

<dt>`acos`</dt>
<dd>In elm-lang/core, as
[`Basics.acos`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#acos)
</dd>

<dt>`asin`</dt>
<dd>In elm-lang/core, as
[`Basics.asin`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#asin)
</dd>

<dt>`atan`</dt>
<dd>In elm-lang/core, as
[`Basics.atan`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#atan)
</dd>

<dt>`atan2`</dt>
<dd>In elm-lang/core, as
[`Basics.atan2`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#atan2)
</dd>

<dt>`ceil`</dt>
<dd>In elm-lang/core, as
[`Basics.ceiling`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#ceiling)
</dd>

<dt>`cos`</dt>
<dd>In elm-lang/core, as
[`Basics.cos`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#cos)
</dd>

<dt>`exp : number -> Float`</dt>
<dd>Returns E to the power of x, where x is the argument, and E is Euler's
constant (2.718…), the base of the natural logarithm.</dd>

<dt>`floor`</dt>
<dd>In elm-lang/core, as
[`Basics.floor`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#floor)
</dd>

<dt>`log : number -> Float`</dt>
<dd>Returns the natural logarithm (log e, also ln) of a number.</dd>

<dt>`max`</dt>
<dd>In elm-lang/core, as
[`List.maximum`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/List#maximum)
</dd>

<dt>`min`</dt>
<dd>In elm-lang/core, as
[`List.minimum`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/List#minimum)
</dd>

<dt>`pow`</dt>
<dd>In elm-lang/core, as
[`Basics.(^)`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#^)
</dd>

<dt>`random : Task x Float`</dt>
<dd>Returns a pseudo-random number between 0 and 1.

Note that there is a more sophisticated implementation of 
[`Random`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Random)
in elm-lang/core. However, this may sometimes be useful if you're in a `Task`
context anyway.</dd>

<dt>`round`</dt>
<dd>In elm-lang/core, as
[`Basics.round`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#round)
</dd>

<dt>`sin`</dt>
<dd>In elm-lang/core, as
[`Basics.sin`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#sin)
</dd>

<dt>`sqrt`</dt>
<dd>In elm-lang/core, as
[`Basics.sqrt`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#sqrt)
</dd>

<dt>`tan`</dt>
<dd>In elm-lang/core, as
[`Basics.tan`](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Basics#tan)
</dd>

</dl>

## WebAPI.Number

See the Mozilla documentation for the
[Number object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number).
Note that things marked "experimental" there have been omitted here.

### Constants

<dl>

<dt>`maxValue : Float`</dt>
<dd>The largest positive representable number.</dd>

<dt>`minValue : Float`</dt>
<dd>The smallest positive representable number - that is, the positive number
closest to zero (without actually being zero).</dd>

<dt>`nan : Float`</dt>
<dd>Special "not a number" value.</dd>

<dt>`negativeInfinity : Float`</dt>
<dd>Special value representing negative infinity; returned on overflow.</dd>

<dt>`positiveInfinity : Float`</dt>
<dd>Special value representing infinity; returned on overflow.</dd>

</dl>

### Functions

<dl>

<dt>`toExponential : number -> String`</dt>
<dd>A string representing the provided number in exponential notation.</dd>

<dt>`toExponentialDigits : Int -> number -> Result String String`</dt>
<dd>Either a string representing the second parameter in exponential notation,
with the requested number of digits after the decimal point (first parameter),
or an error. An error should not occur if the requested number of digits is
between 0 and 20.</dd>

<dt>`toFixed : number -> String`</dt>
<dd>A string representing the provided number in fixed-point notation.</dd>

<dt>`toFixedDigits : Int -> number -> Result String String`</dt>
<dd>Either a string representing the second parameter in fixed-point notation,
with the requested number of digits after the decimal point (first parameter),
or an error. An error should not occur if the requested number of digits is
between 0 and 20.</dd>

<dt>`toLocaleString`</dt>
<dd>Not implemented for the moment, since localization requires some thought.</dd>

<dt>`toPrecisionDigits : Int -> number -> Result String String`</dt>
<dd>Either a string representing the second parameter in fixed-point or
exponential notation, rounded to the requested number of significant digits
(first parameter), or an error. An error should not occur if the requested
number of digits is between 0 and 20.</dd>

<dt>`toStringUsingBase : Int -> number -> Result String String`</dt>
<dd>Either a string representing the second parameter using the requested base
(first parameter), or an error. An error should not occur if the requested base
is between 2 and 36.</dd>

</dl>

## WebAPI.RegExp

Generally speaking, regular expressions are handled by the
[`Regex` module](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Regex)
in elm-lang/core.

TODO: Check if anything is missing.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).

## WebAPI.String

Generally speaking, strings are dealt with by the
[`String` module](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/String)
in elm-lang/core. 

TODO: Check if anything is missing.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String).

## WebAPI.Window

TODO.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Window).

