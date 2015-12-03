module WebAPI.Function
    ( Function, length, decoder, encode, apply, pure, construct
    , Callback, javascript, elm
    , Response, return, throw, asyncAndReturn, asyncAndThrow, syncOrReturn, syncOrThrow
    , Error, error, message
    ) where

{-| Support for Javascript functions. Basically, this provides two capabilities:

* You can call Javascript functions from Elm.
* You can provide Elm functions to Javascript to be called back from Javascript.

See [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function)

## Types

@docs Function, length, Error, error, message

## Obtaining functions from Javascript

@docs javascript, decoder

## Calling Functions

@docs apply, pure, construct

## Providing functions to Javascript

@docs encode, elm, Callback

@docs Response, return, throw, asyncAndReturn, asyncAndThrow, syncOrReturn, syncOrThrow
-}

import Task exposing (Task)
import Json.Encode as JE
import Json.Decode as JD

import Native.WebAPI.Function


{- -----
   Types
   ----- -}


{-| Opaque type representing a Javascript function. -}
type Function = Function


{-| The number of arguments expected by a function. -}
length : Function -> Int
length = Native.WebAPI.Function.length


{-| Opaque type representing a Javascript exception. -}
type Error = Error


{-| Construct an error to be thrown in a Javascript callback. Normally, one
does not want errors to be thrown. However, there may be some Javascript APIs
that expect callbacks to throw errors. So, this makes that possible.
-}
error : String -> Error
error = Native.WebAPI.Function.error


{-| Gets an error's message. -}
message : Error -> String
message = Native.WebAPI.Function.message


{- -----------------------------------
   Obtaining functions from Javascript 
   ----------------------------------- -}


{-| Produce a Javascript function given a list of parameter names and a
Javascript function body.
-}
javascript : List String -> String -> Result Error Function
javascript = Native.WebAPI.Function.javascript


{-| Extract a function. -}
decoder : JD.Decoder Function
decoder = Native.WebAPI.Function.decoder


{- -----------------
   Calling Functions
   ----------------- -}


{-| Call a function, using the supplied value for "this", and the supplied
parameters. If you don't want to supply a `this`, you could use
`Json.Encode.null`.
-}
apply : JE.Value -> List JE.Value -> Function -> Task Error JD.Value
apply = Native.WebAPI.Function.apply


{-| Call a 'pure' function, using the supplied value for "this", and the
supplied parameters. If you don't want to supply a `this`, you could use
`Json.Encode.null`.

It is your responsibility to know that the function is 'pure' -- that is:

* it has no side-effects
* it does not mutate its arguments (or anything else)
* it returns the same value for the same arguments every time

The type-checker can't verify this for you. If you have any doubt, use
`apply` instead.
-}
pure : JE.Value -> List JE.Value -> Function -> Result Error JD.Value
pure = Native.WebAPI.Function.pure


{-| Use a function as a constructor, via `new`, with the supplied parameters. -}
construct : List JE.Value -> Function -> Task Error JD.Value
construct = Native.WebAPI.Function.construct


{- ---------------------------------
   Providing functions to Javascript
   --------------------------------- -}


{-| Encode a function. -}
encode : Function -> JE.Value
encode = Native.WebAPI.Function.encode


{-| Given an Elm implementation, produce a function which can be called back
from Javascript.
-}
elm : Callback x a -> Function
elm = Native.WebAPI.Function.elm


{-| An Elm function which can be supplied to Javascript code as a callback.

When the function is invoked from Javascript, the parameter will be a
Javascript array in which the first element is whatever `this` was, and the
remaining elements are the parameters to the javascript function. So, you'll
want to apply some `Json.Decode` decoders to get Elm types out of that.

Since you're being given an array which you should independently know the
length of, you'll probably want to make use of `Json.Decode.tuple1`,
`Json.Decode.tuple2`, etc., depending on how many arguments you're expecting.
And, remember that the first element of the Javascript array is not the first
argument, but instead whatever `this` was, so you may or may not be interested
in it. If you just want to ignore it, you could use `Json.Decode.succeed`.

For instance, let's suppose you're expecting 2 parameters which are integers,
and you don't care about `this`. In that case, you might decode with:

    JD.tuple3 (,,) (JD.succeed Nothing) JD.int JD.int

When running `Json.Decode.decodeValue`, you'd then end up with a
`(Maybe a, Int, Int)` or an error.

Your Elm function should return a `Response`, which controls the return value
of the Javascript function, and allows for the execution of a `Task`.
-}
type alias Callback x a =
    JD.Value -> Response x a


{-| An opaque type representing your response to a function invocation from
Javascript, i.e. a response to a callback.
-}
type Response x a
    = Result (Result Error JE.Value)
    | Async (Task x a) (Result Error JE.Value)
    | Sync (Task Error JE.Value) (Result Error JE.Value)


{-| Respond to a Javascript function call with the supplied return value. -}
return : JE.Value -> Response x a
return = Result << Result.Ok


{-| Respond to a Javascript function call by throwing an error. Normally,
you do not want to throw Javascript errors, but there may be some Javascript
APIs that expect callbacks to do so. This makes it possible.
-}
throw : Error -> Response x a
throw = Result << Result.Err


{-| Respond to a Javascript function call using the supplied return value,
and also perform a `Task`.

This is like `return`, except that the supplied `Task` is also immediately
performed when the Javascript function is called. The `Task` is presumed to be
asynchronous, so its completion does not affect the return value used for the
Javascript function.

If you want to 'promote' the callback into the normal flow of your app, you
might want to use `Signal.send` to send an action to an address. (Note that
`Signal.send` is asynchronous).
-}
asyncAndReturn : Task x a -> JE.Value -> Response x a
asyncAndReturn task value =
    Async task (Result.Ok value)


{-| Respond to a Javascript function call by throwing an error,
and also perform a `Task`.

This is like `asyncReturn`, except an error will be thrown.
-}
asyncAndThrow : Task x a -> Error -> Response x a
asyncAndThrow task value =
    Async task (Result.Err value)


{-| Respond to a Javascript function call by executing a `Task`, and using
the completion of the `Task` to control the function's return value.

If the `Task` succeeds, the result will be used as the return value for the
Javascript function. This allows you to chain other tasks in order to provide
a return value -- so long as the other tasks are synchronous.

If the `Task` fails, the result will be thrown as an error. Normally, one does
not want to throw Javascript errors, but there may be some Javascript APIs that
expect callbacks to do so.

If the `Task` turns out to be asynchronous -- that is, if it fails to complete
before the Javascript function returns -- then the supplied `JE.Value` will be
used as the default return value.
-}
syncOrReturn : Task Error JE.Value -> JE.Value -> Response x a
syncOrReturn task value =
    Sync task (Result.Ok value)


{-| Respond to a Javascript function call by executing a `Task`, and using
the completion of the `Task` to control the function's return value.

If the `Task` succeeds, the result will be used as the return value for the
Javascript function. This allows you to chain other tasks in order to provide
a return value -- so long as the other tasks are synchronous.

If the `Task` fails, the result will be thrown as an error. Normally, one does
not want to throw Javascript errors, but there may be some Javascript APIs that
expect callbacks to do so.

If the `Task` turns out to be asynchronous -- that is, if it fails to complete
before the Javascript function returns -- then the supplied `Error` will be
thrown.
-}
syncOrThrow : Task Error JE.Value -> Error -> Response x a
syncOrThrow task value =
    Sync task (Result.Err value)
