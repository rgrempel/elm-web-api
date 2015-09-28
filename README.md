# elm-browser

The purpose of this package is to expose facilities provided by the Javascript
runtime in web browsers for use in Elm.

In order for Elm to use facilities provided by the Javascript runtime in a web
browser, it is necessary to write "native" code in Elm. Sometimes this has
already been done for you, either in Elm's core libraries or in another
package. However, sometimes it has not been done, so you would have to write
the native code yourself. But, writing native code is a little tricky, and it's
inefficient for people to have to do it themselves.

So, for each facility provided by a browser's Javascript runtime, this package
either provides a wrapper in Elm "native" code, or indicates which package
already does so.

The wrappers provided here are intentionally simplistic. The idea is to do as
little as possible to make the facility available in Elm -- any additional
logic or convenience can be supplied by other packages on top of this.

## Browser.Global

See the Mozilla documentation for
[function properties](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects#Function_properties).

<dl>

<dt>`eval`</dt>
<dd>Not implemented, since it is an abomination.</dd>

<dt>`isFinite`</dt>
<dd>In elm-lang/core, as `Basics.isInfinite` (presumably with the sense reversed).</dd>

<dt>`isNan`</dt>
<dd>In elm-lang/core, as `Basics.isNan`</dd>

<dt>`parseFloat`</dt>
<dd>In elm-lang/core, as `String.toFloat`</dd>

<dt>`parseInt`</dt>
<dd>In elm-lang/core, as `String.toInt`</dd>

<dt>`decodeURI`</dt>
<dd>Not implemented, since you will generally want `decodeURIComponent` instead.</dd>

<dt>`decodeURIComponent`</dt>
<dd>In evancz/elm-http, as `Http.uriDecode`</dd>

<dt>`encodeURI`</dt>
<dd>Not implemented, since you will generally want `encodeURIComponent` instead.</dd>

<dt>`encodeURIComponent`</dt>
<dd>In evancz/elm-http, as `Http.uriEncode`</dd>

## Browser.Math

See the Mozilla documentation for the
[Math object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math).
Note that things marked "experimental" there have been omitted here.

### Constants

<dl>

<dt>`E`</dt>
<dd>In elm-lang/core, as `Basics.e`</dd>

<dt>`ln2 : Float`</dt>
<dd>Natural logarithm of 2, approximately 0.693.</dd>

<dt>`ln10 : Float`</dt>
<dd>Natural logarithm of 2, approximately 2.303.</dd>

<dt>`log2e : Float`</dt>
<dd>Base 2 logarithm of E, approximately 1.443</dd>

<dt>`log10e : Float`</dt>
<dd>Base 10 logarithm of E, approximately 0.434</dd>

<dt>`PI`</dt>
<dd>In elm-lang/core, as `Basics.pi`</dd>

<dt>`sqrt1_2 : Float`</dt>
<dd>Square root of 1/2; equivalently, 1 over the square root of 2, approximately 0.707.</dd>

<dt>`sqrt2 : Float`</dd>
<dd>Square root of 2, approximately 1.414.</dd>

</dl>

### Functions

<dl>

<dt>`abs`</dt>
<dd>In elm-lang/core, as `Basics.abs`</dd>

<dt>`acos`</dt>
<dd>In elm-lang/core, as `Basics.acos`</dd>

<dt>`asin`</dt>
<dd>In elm-lang/core, as `Basics.asin`</dd>

<dt>`atan`</dt>
<dd>In elm-lang/core, as `Basics.atan`</dd>

<dt>`atan2`</dt>
<dd>In elm-lang/core, as `Basics.atan2`</dd>

<dt>`ceil`</dt>
<dd>In elm-lang/core, as `Basics.ceiling`</dd>

<dt>`cos`</dt>
<dd>In elm-lang/core, as `Basics.cos`</dd>

<dt>`exp : number -> Float`</dt>
<dd>Returns E to the power of x, where x is the argument, and E is Euler's
constant (2.718…), the base of the natural logarithm.</dd>

<dt>`floor`</dt>
<dd>In elm-lang/core, as `Basics.floor`</dd>

<dt>`log : number -> Float`</dt>
<dd>Returns the natural logarithm (log e, also ln) of a number.</dd>

<dt>`max`</dt>
<dd>In elm-lang/core, as `List.maximum`</dd>

<dt>`min`</dt>
<dd>In elm-lang/core, as `List.minimum`</dd>

<dt>`pow`</dt>
<dd>In elm-lang/core, as `Basics.(^)`</dd>

<dt>`random : Task x Float`</dt>
<dd>Returns a pseudo-random number between 0 and 1.

Note that there is a more sophisticated implementation of `Random` in
elm-lang/core. However, this may sometimes be useful if you're in a `Task`
context anyway.</dd>

<dt>`round`</dt>
<dd>In elm-lang/core, as `Basics.round`</dd>

<dt>`sin`</dt>
<dd>In elm-lang/core, as `Basics.sin`</dd>

<dt>`sqrt`</dt>
<dd>In elm-lang/core, as `Basics.sqrt`</dd>

<dt>`tan`</dt>
<dd>In elm-lang/core, as `Basics.tan`</dd>

</dl>

## Browser.Number

See the Mozilla documentation for the
[Number object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number).
Note that things marked "experimental" have been omitted here.

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

## Browser.Date

Generally speaking, dates are dealt with in elm-lang/core. I will make an
itemized list later.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date).

## Browser.String

Generally speaking, strings are dealt with in elm-lang/core. I will make
an itemized list later.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String).

## Browser.RegExp

Generally speaking, regexp ...

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).

## Browser.JSON

Generally speaking, ...

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON).

## Browser.Intl

Internationalization is ...

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl).

## Browser.Window

...

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Window).

## Browser.DOM

Most DOM modifications are done by `main`. But, there are a few things one can usefully modify
outside of the embedding.
