module WebAPI.Cookie
    ( get, set
    , Options, setWith, defaultOptions
    , Error(Error, Disabled), enabled
    ) where

{-| Wrap the browser's 
[`document.cookie`](https://developer.mozilla.org/en-US/docs/Web/API/Document/cookie)
object.

## Getting cookies

@docs get

## Setting cookies

@docs set, setWith, Options, defaultOptions

## Errors

@docs Error, enabled
-}

import Native.WebAPI.Cookie

import Task exposing (Task)
import String exposing (split, trim, join)
import Dict exposing (Dict, insert)
import Time exposing (inSeconds, Time)
import Date exposing (Date)
import List


{-| A name for a cookie. -}
type alias Key = String


{-| The value of a cookie. -}
type alias Value = String


{-| Tasks will fail with `Disabled` if the user has disabled cookies, or
with `Error` for other errors.
-}
type Error
    = Disabled
    | Error String


{-| Whether cookies are enabled, according to the browser's
`navigator.cookieEnabled`. -}
enabled : Task x Bool
enabled = Native.WebAPI.Cookie.enabled


{-| A `Task` which, when executed, will succeed with the cookies, or fail with an
error message if (for instance) cookies have been disabled in the browser.

In the resulting `Dict`, the keys and values are the key=value pairs parsed from
Javascript's `document.cookie`. The keys and values will have been uriDecoded.
-}
get : Task Error (Dict Key Value)
get = Task.map cookieString2Dict getString


getString : Task Error String
getString = Native.WebAPI.Cookie.getString


{- We pipeline the various operations inside the foldl so that we don't
iterate over the cookies more then once.  Note that the uriDecode needs to
happen after the split on ';' (to divide into key-value pairs) and the split on
'=' (to divide the keys from the values).
-}
cookieString2Dict : String -> Dict Key Value
cookieString2Dict =
    let
        addCookieToDict =
            trim >> split "=" >> List.map uriDecode >> addKeyValueToDict

        addKeyValueToDict keyValueList =
            case keyValueList of
                key :: value :: _ -> insert key value
                _ -> identity

    in
        List.foldl addCookieToDict Dict.empty << split ";"


{-| A task which will set a cookie using the provided key and value. The key
and value will both be uriEncoded.

The task will fail with an error message if cookies have been disabled in the
browser.
-}
set : Key -> Value -> Task Error ()
set = setWith defaultOptions


{-| Options which you can provide to setWith. -}
type alias Options =
    { path : Maybe String
    , domain : Maybe String
    , maxAge : Maybe Time
    , expires : Maybe Date 
    , secure : Maybe Bool
    }


{-| The default options, in which all options are set to Nothing.

You can use this as a starting point for `setWith`, in cases where you only
want to specify some options.
-}
defaultOptions : Options
defaultOptions =
    { path = Nothing
    , domain = Nothing
    , maxAge = Nothing
    , expires = Nothing
    , secure = Nothing
    }


{-| A task which will set a cookie using the provided options, key, and value.
The key and value will be uriEncoded, as well as the path and domain options
(if provided).

The task will fail with an error message if cookies have been disabled in
the browser.
-}
setWith : Options -> Key -> Value -> Task Error ()
setWith options key value =
    let
        andThen =
            flip Maybe.andThen

        handlers =
            [ always <| Just <| (uriEncode key) ++ "=" ++ (uriEncode value)
            , .path >> andThen (\path -> Just <| "path=" ++ uriEncode path)
            , .domain >> andThen (\domain -> Just <| "domain=" ++ uriEncode domain)
            , .maxAge >> andThen (\age -> Just <| "max-age=" ++ toString (inSeconds age))
            , .expires >> andThen (\expires -> Just <| "expires=" ++ dateToUTCString expires)
            , .secure >> andThen (\secure -> if secure then Just "secure" else Nothing)
            ]

        cookieStrings =
            List.filterMap ((|>) options) handlers

    in
        setString <| join ";" cookieStrings


setString : String -> Task Error ()
setString =
    Native.WebAPI.Cookie.setString


dateToUTCString : Date -> String
dateToUTCString =
    Native.WebAPI.Cookie.dateToUTCString


uriEncode : String -> String
uriEncode =
    Native.WebAPI.Cookie.uriEncode


uriDecode : String -> String
uriDecode =
    Native.WebAPI.Cookie.uriDecode
