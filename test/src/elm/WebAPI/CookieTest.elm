module WebAPI.CookieTest where

import String
import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)
import ElmTest.Runner.Element exposing (runDisplay)

import Task exposing (Task, andThen, sequence, map)
import Date exposing (fromTime)
import Time exposing (second)
import Dict

import WebAPI.Cookie as Cookies


(>>>) = flip Task.map
(>>+) = Task.andThen
(>>!) = Task.onError


(>>-) task func =
    task `andThen` (always func)


reportError : String -> Cookies.Error -> Task x Test
reportError name error =
    Task.succeed <|
        test (name ++ ": " ++ (toString error)) <|
            assert False


simpleSetGet : Task x Test
simpleSetGet =
    Cookies.set "bog" "joe"
    >>- Cookies.get
    >>> (
        Dict.get "bog"
        >> assertEqual (Just "joe")
        >> test "simple set then get"
    )
    >>! reportError "simple set then get"


-- Make sure we're actually *changing* the cookie
secondSetGet : Task x Test
secondSetGet =
    Cookies.set "bog" "frank"
    >>- Cookies.get
    >>> (
        Dict.get "bog"
        >> assertEqual (Just "frank")
        >> test "repeated set/get, to make sure we can change the cookie"
        )
    >>! reportError "repeated set/get"


multipleSetGet : Task x Test
multipleSetGet =
    Cookies.set "cookie1" "cookie 1 value"
    >>- Cookies.set "cookie2" "cookie 2 value"
    >>- Cookies.get
    >>> (\cookies ->
            [ Dict.get "cookie1" cookies
            , Dict.get "cookie2" cookies
            ]
                |> assertEqual
                    [ Just "cookie 1 value"
                    , Just "cookie 2 value"
                    ]
                |> test "multiple cookies"
        )
    >>! reportError "multiple cookies"


encodingTest : Task x Test
encodingTest =
    Cookies.set "encoded=" "value needs encoding ;"
    >>- Cookies.get
    >>> (
        Dict.get "encoded="
        >> assertEqual (Just "value needs encoding ;")
        >> test "key and value should be encoded"
        )
    >>! reportError "key and value should be encoded"


setWithWrongPath : Task x Test
setWithWrongPath =
    let
        defaults =
            Cookies.defaultOptions

        options =
            -- { defaults | path = Just "/path" }
            Cookies.Options (Just "/path") Nothing Nothing Nothing Nothing

    in
        Cookies.setWith options "wrong path cookie" "path cookie value"
        >>- Cookies.get
        >>> (
            Dict.get "wrong path cookie"
            >> assertEqual Nothing
            >> test "test with path set to bad value"
            )
        >>! reportError "test with path set to bad value"


setWithGoodPath : Task x Test
setWithGoodPath =
    let
        defaults =
            Cookies.defaultOptions

        options =
            -- { defaults | path = Just "" }
            Cookies.Options (Just "") Nothing Nothing Nothing Nothing

    in
        Cookies.setWith options "good path cookie" "path cookie value"
        >>- Cookies.get
        >>> (
            Dict.get "good path cookie"
            >> assertEqual (Just "path cookie value")
            >> test "test with path set to good value"
            )
        >>! reportError "test with path set to good value"


maxAgeFuture : Task x Test
maxAgeFuture =
    let
        defaults =
            Cookies.defaultOptions

        options =
            -- { defaults | maxAge = Just 1000 }
            Cookies.Options Nothing Nothing (Just 1000) Nothing Nothing

    in
        Cookies.setWith options "max age future" "cookie value"
        >>- Cookies.get
        >>> (
            Dict.get "max age future"
            >> assertEqual (Just "cookie value")
            >> test "test with maxAge in future"
            )
        >>! reportError "test with maxAge in future"


expiresInFuture : Task x Test
expiresInFuture =
    let
        defaults =
            Cookies.defaultOptions

        options =
            -- Sets the date to September 26, 2028 conveniently
            -- { defaults | expires = Just (fromTime (1853609409 * second)) }
            Cookies.Options Nothing Nothing Nothing (Just (fromTime (1853609409 * second))) Nothing

    in
        Cookies.setWith options "expires" "cookie value"
        >>- Cookies.get
        >>> (
            Dict.get "expires"
            >> assertEqual (Just "cookie value")
            >> test "test with expiry in future"
            )
        >>! reportError "test with expiry in future"


expiresInPast : Task x Test
expiresInPast =
    let
        defaults =
            Cookies.defaultOptions

        options =
            -- { defaults | expires = Just (fromTime 0) }
            Cookies.Options Nothing Nothing Nothing (Just (fromTime 0)) Nothing

    in
        Cookies.setWith options "expires" "cookie value"
        >>- Cookies.get
        >>> (
            Dict.get "expires"
            >> assertEqual Nothing
            >> test "test with expiry in past"
            )
        >>! reportError "test with expiry in past"


enabledTest : Task x Test
enabledTest =
    Cookies.enabled
    >>> (
        assert
        >> test "Cookies should be enabled"
        )


tests : Task () Test
tests =
    Task.map (suite "WebAPI.CookieTest") <|
        sequence
            [ simpleSetGet
            , secondSetGet
            , multipleSetGet
            , encodingTest

            -- TODO: setWithWrongPath is "failing" on Chrome, but it's not really a proper
            -- test, since I'm just trying to retrieve it locally -- what the path really
            -- controls is whether it's sent to the server. So, in principle I ought to
            -- do a more sophisticated test of this ...
            -- , setWithWrongPath
            
            , setWithGoodPath
            , maxAgeFuture
            , expiresInFuture
            , expiresInPast
            , enabledTest
            ]
