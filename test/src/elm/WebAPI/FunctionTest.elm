module WebAPI.FunctionTest where

import ElmTest.Test exposing (..)
import ElmTest.Assertion exposing (..)
import Task exposing (Task, sequence, succeed, andThen)

import TestUtil exposing (sample)
import WebAPI.Function as Function
import Json.Encode as JE
import Json.Decode as JD


and : (a -> Task x b) -> Task x a -> Task x b
and = flip Task.andThen


recover : (x -> Task y a) -> Task x a -> Task y a
recover = flip Task.onError


testGoodJavascript : Task () Test
testGoodJavascript =
    let
        function =
            Function.javascript
                ["a", "b"]
                "return a + b;"

    in
        function
            |> Task.fromResult
            |> and (Function.apply JE.null [JE.int 2, JE.int 4])
            |> Task.map (JD.decodeValue JD.int)
            |> Task.map (assertEqual (Ok 6))
            |> Task.map (test "basic good javascript should work")
            |> Task.mapError (always ())


testBoundJavascript : Task () Test
testBoundJavascript =
    let
        function =
            Function.javascript
                ["a"]
                "return a + this;"

    in
        function
            |> Task.fromResult
            |> and (Function.apply (JE.int 4) [JE.int 2])
            |> Task.map (JD.decodeValue JD.int)
            |> Task.map (assertEqual (Ok 6))
            |> Task.map (test "javascript with this should work")
            |> Task.mapError (always ())


testGoodConstruct : Task () Test
testGoodConstruct =
    let
        function =
            Function.javascript
                ["a"]
                "this.val = a;"

    in 
        function
            |> Task.fromResult
            |> and (Function.construct [JE.int 17])
            |> Task.map (JD.decodeValue (JD.at ["val"] JD.int))
            |> Task.map (assertEqual (Ok 17))
            |> Task.map (test "using function as constructor should work")
            |> Task.mapError (always ())


testConstructException : Task () Test
testConstructException =
    let
        function =
            Function.javascript
                ["a", "b"]
                "throw new Error(\"An error\");"

    in
        function
            |> Task.fromResult
            |> and (Function.construct [])
            |> Task.toMaybe
            |> Task.map (assertEqual Nothing)
            |> Task.map (test "Task should have errored")


testExposeJavascriptStuff : Task () Test
testExposeJavascriptStuff =
    let
        function =
            Function.javascript
                []
                "return Math.PI;"

    in
        function
            |> Task.fromResult
            |> and (Function.apply JE.null [])
            |> Task.map (JD.decodeValue JD.float)
            |> Task.map (assertEqual (Ok Basics.pi))
            |> Task.map (test "should be albe to get Math.PI")
            |> Task.mapError (always ())


testJavascriptWithException : Task x Test
testJavascriptWithException =
    let
        function =
            Function.javascript
                ["a", "b"]
                "throw new Error(\"An error\");"

    in
        function
            |> Task.fromResult
            |> and (Function.apply JE.null [])
            |> Task.toMaybe
            |> Task.map (assertEqual Nothing)
            |> Task.map (test "Task should have errored")


testBadJavascript : Test
testBadJavascript =
    let
        function =
            Function.javascript
                ["a", "b"]
                "returned 17;"

    in
        function
            |> Result.toMaybe
            |> assertEqual Nothing
            |> test "Javascript with syntax error should error"


testSimpleCallback : Task () Test
testSimpleCallback =
    let
        callback params =
            Function.return (JE.int 7)

        function =
            Function.elm callback

    in
        Function.apply JE.null [] function
            |> Task.map (JD.decodeValue JD.int)
            |> Task.map (assertEqual (Ok 7))
            |> Task.map (test "simple callback should work")
            |> Task.mapError (always ())


testCallbackThatDoesStuff : Task () Test
testCallbackThatDoesStuff =
    let
        callback params =
            let
                decoder =
                    JD.tuple3 (,,) (JD.succeed Nothing) JD.int JD.int

            in
                case JD.decodeValue decoder params of
                    Ok (this, param1, param2) ->
                        Function.return (JE.int (param1 + param2))

                    Err error ->
                        Function.throw (Function.error error)
                
        function =
            Function.elm callback

    in
        Function.apply (JE.int 7) [JE.int 5, JE.int 12] function
            |> Task.map (JD.decodeValue JD.int)
            |> Task.map (assertEqual (Ok 17))
            |> Task.map (test "callback that does stuff should work")
            |> Task.mapError (always ())


testCallbackThatDoesStuffWithThis : Task () Test
testCallbackThatDoesStuffWithThis =
    let
        callback params =
            let
                decoder =
                    JD.tuple3 (,,) JD.int JD.int JD.int

            in
                case JD.decodeValue decoder params of
                    Ok (self, param1, param2) ->
                        Function.return (JE.int (self + param1 + param2))

                    Err error ->
                        Function.throw (Function.error error)
                
        function =
            Function.elm callback

    in
        Function.apply (JE.int 7) [JE.int 5, JE.int 12] function
            |> Task.map (JD.decodeValue JD.int)
            |> Task.map (assertEqual (Ok 24))
            |> recover (\error -> Task.succeed (assertEqual "" (Function.message error)))
            |> Task.map (test "callback that does stuff should work")


testSyncOrReturnSync : Task () Test
testSyncOrReturnSync =
    let
        callback params =
            Function.syncOrReturn
                (Task.succeed (JE.int 7))
                (JE.int 8)

        function =
            Function.elm callback

    in
        Function.apply JE.null [] function
            |> Task.map (JD.decodeValue JD.int)
            |> Task.map (assertEqual (Ok 7))
            |> Task.map (test "syncOrReturn should use task when sync")
            |> Task.mapError (always ())


testSyncOrReturnSyncFail : Task () Test
testSyncOrReturnSyncFail =
    let
        callback params =
            Function.syncOrReturn
                (Task.fail (Function.error "failed"))
                (JE.int 8)

        function =
            Function.elm callback

    in
        Function.apply JE.null [] function
            |> Task.toMaybe
            |> Task.map (assertEqual Nothing)
            |> Task.map (test "syncOrReturn should throw when sync and task fails")


testSyncOrReturnAsync : Task () Test
testSyncOrReturnAsync =
    let
        callback params =
            Function.syncOrReturn
                (Task.sleep 20 `Task.andThen` always (Task.succeed (JE.int 7)))
                (JE.int 8)

        function =
            Function.elm callback

    in
        Function.apply JE.null [] function
            |> Task.map (JD.decodeValue JD.int)
            |> Task.map (assertEqual (Ok 8))
            |> Task.map (test "syncOrReturn should use default when async")
            |> Task.mapError (always ())


testSyncOrThrowSync : Task () Test
testSyncOrThrowSync =
    let
        callback params =
            Function.syncOrThrow
                (Task.succeed (JE.int 7))
                (Function.error "Wasn't sync after all")

        function =
            Function.elm callback

    in
        Function.apply JE.null [] function
            |> Task.map (JD.decodeValue JD.int)
            |> Task.map (assertEqual (Ok 7))
            |> Task.map (test "syncOrThrow should use task when sync")
            |> Task.mapError (always ())


testSyncOrThrowAsync : Task () Test
testSyncOrThrowAsync =
    let
        callback params =
            Function.syncOrThrow
                (Task.sleep 20 `Task.andThen` always (Task.succeed (JE.int 7)))
                (Function.error "Wasn't sync after all")

        function =
            Function.elm callback

    in
        Function.apply JE.null [] function
            |> Task.toMaybe
            |> Task.map (assertEqual Nothing)
            |> Task.map (test "syncOrThrow should throw when async")


asyncMail : Signal.Mailbox Int
asyncMail = Signal.mailbox 0


testAsyncAndReturn : Task () Test
testAsyncAndReturn =
    let
        callback params =
            Function.asyncAndReturn
                (Signal.send asyncMail.address 7)
                (JE.int 18)

        returnTask =
            Function.apply JE.null [] (Function.elm callback)
                |> Task.map (JD.decodeValue JD.int)

        sampleTask =
            Task.sleep 10
                |> and (always (TestUtil.sample asyncMail.signal))

    in
        Task.mapError (always ()) <|
            Task.map2 (\return sample ->
                test "asyncAndReturn" <|
                    case return of
                        Ok 18 ->
                            assertEqual 7 sample

                        _ ->
                            assert False 
            ) returnTask sampleTask


testAsyncAndThrow : Task () Test
testAsyncAndThrow =
    let
        callback params =
            Function.asyncAndThrow
                (Signal.send asyncMail.address 23)
                (Function.error "Failure")

        returnTask =
            Function.apply JE.null [] (Function.elm callback)
                |> Task.toMaybe
 

        sampleTask =
            Task.sleep 10
                |> and (always (TestUtil.sample asyncMail.signal))

    in
        Task.map2 (\return sample ->
            test "asyncAndReturn" <|
                case return of
                    Nothing ->
                        assertEqual 23 sample

                    _ ->
                        assert False 
        ) returnTask sampleTask


testErrorCallback : Task () Test
testErrorCallback =
    let
        callback params =
            Function.throw (Function.error "message")

        function =
            Function.elm callback

    in
        Function.apply JE.null [] function
            |> Task.toMaybe
            |> Task.map (assertEqual Nothing)
            |> Task.map (test "error callback should have errored")


testMessage : Test
testMessage =
    Function.message (Function.error "Failed...")
        |> assertEqual "Failed..."
        |> test "Message should get out what error put in"


testDecoderSuccess : Test
testDecoderSuccess =
    let
        callback params =
            Function.throw (Function.error "message")

        value =
            Function.encode (Function.elm callback)

        result =
            JD.decodeValue Function.decoder value
    
    in
        test "Decoder should decode function" <|
            case result of
                Ok _ ->
                    assert True

                Err _ ->
                    assert False


testDecoderFailure : Test
testDecoderFailure =
    test "Decoder should not decode integer" <|
        case JD.decodeValue Function.decoder (JE.int 7) of
            Ok _ ->
                assert False 

            Err _ ->
                assert True


tests : Task () Test
tests =
    Task.map (suite "WebAPI.FunctionTest") <|
        sequence <|
            [ testGoodJavascript
            , testBoundJavascript
            , testJavascriptWithException
            , testGoodConstruct
            , testConstructException
            , testExposeJavascriptStuff
            , testCallbackThatDoesStuff
            , testCallbackThatDoesStuffWithThis
            , testSimpleCallback
            , testErrorCallback
            , testSyncOrReturnSync
            , testSyncOrReturnSyncFail
            , testSyncOrReturnAsync
            , testSyncOrThrowSync
            , testSyncOrThrowAsync
            , testAsyncAndReturn
            , testAsyncAndThrow
            ]
            ++
            List.map Task.succeed
                [ testBadJavascript
                , testMessage
                , testDecoderSuccess
                , testDecoderFailure
                ]

