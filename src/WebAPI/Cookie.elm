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

import Task exposing (Task)
import String exposing (split, trim, join)
import Dict exposing (Dict, insert)
import Time exposing (inSeconds, Time)
import Date exposing (Date)
import Json.Decode as JD
import Json.Encode as JE
import List

import WebAPI.Window exposing (encodeURIComponent, decodeURIComponent)
import WebAPI.Function exposing (Function)
import WebAPI.Date


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


and = flip Task.andThen


cookieEnabledDecoder : JD.Decoder Bool
cookieEnabledDecoder =
    JD.at ["navigator", "cookieEnabled"] JD.bool


{-| Whether cookies are enabled, according to the browser's
`navigator.cookieEnabled`. -}
enabled : Task x Bool
enabled =
    WebAPI.Window.value
        |> Task.map (JD.decodeValue cookieEnabledDecoder)
        |> Task.map (\result ->
                case result of
                    Ok bool ->
                        bool

                    Err error ->
                        Debug.crash "Could not decode navigator.cookieEnabled"
            )


{-| A `Task` which, when executed, will succeed with the cookies, or fail with an
error message if (for instance) cookies have been disabled in the browser.

In the resulting `Dict`, the keys and values are the key=value pairs parsed from
Javascript's `document.cookie`. The keys and values will have been uriDecoded.
-}
get : Task Error (Dict Key Value)
get = Task.map cookieString2Dict getString


cookieDecoder : JD.Decoder String
cookieDecoder =
    JD.at ["document", "cookie"] JD.string


getString : Task Error String
getString =
    enabled `Task.andThen` \e ->
        if e
            then
                WebAPI.Window.value
                    |> Task.map (JD.decodeValue cookieDecoder)
                    |> and Task.fromResult
                    |> Task.mapError Error

            else
                Task.fail Disabled


{- We pipeline the various operations inside the foldl so that we don't
iterate over the cookies more then once.  Note that the uriDecode needs to
happen after the split on ';' (to divide into key-value pairs) and the split on
'=' (to divide the keys from the values).
-}
cookieString2Dict : String -> Dict Key Value
cookieString2Dict =
    let
        addCookieToDict =
            trim >> split "=" >> List.map decodeURIComponent >> addKeyValueToDict

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
            [ always <| Just <| (encodeURIComponent key) ++ "=" ++ (encodeURIComponent value)
            , .path >> andThen (\path -> Just <| "path=" ++ encodeURIComponent path)
            , .domain >> andThen (\domain -> Just <| "domain=" ++ encodeURIComponent domain)
            , .maxAge >> andThen (\age -> Just <| "max-age=" ++ toString (inSeconds age))
            , .expires >> andThen (\expires -> Just <| "expires=" ++ WebAPI.Date.utcString expires)
            , .secure >> andThen (\secure -> if secure then Just "secure" else Nothing)
            ]

        cookieStrings =
            List.filterMap ((|>) options) handlers

    in
        setString <| join ";" cookieStrings


setString : String -> Task Error ()
setString value =
    enabled
        |> and (\e ->
            if e
                then
                    WebAPI.Function.apply JE.null [JE.string value] setStringFunction
                        |> Task.mapError (WebAPI.Function.message >> Error)
                        |> Task.map (always ())

                else
                    Task.fail Disabled
           )


setStringFunction : Function
setStringFunction =
    let
        result =
            WebAPI.Function.javascript
                ["value"]
                "document.cookie = value;"

    in
        case result of
            Ok func ->
                func

            Err error ->
                Debug.crash "Error compiling perfectly good function."
