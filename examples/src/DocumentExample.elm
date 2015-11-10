module DocumentExample where

import Effects exposing (Effects, Never)
import StartApp exposing (App)
import Task exposing (Task, toResult)
import Html exposing (Html, h4, div, text, button, p, input)
import Html.Attributes exposing (id, style)
import Html.Events exposing (onClick)
import Signal exposing (Signal, Mailbox, Address)

import WebAPI.Event exposing
    ( Listener, removeListener
    , remove, send, performTask, preventDefault
    , stopPropagation, stopImmediatePropagation
    )

import WebAPI.Document exposing
    ( getReadyState, ReadyState(..)
    , domContentLoaded, loaded
    , once, on
    )


app : App Model
app =
    StartApp.start
        { init = init
        , update = update
        , view = view
        , inputs = [ mailbox.signal ]
        }


mailbox : Mailbox Action
mailbox = Signal.mailbox NoOp


main : Signal Html
main = app.html


port tasks : Signal (Task.Task Never ())
port tasks = app.tasks


type alias Model =
    { log : List Log
    , clickListener : Maybe Listener
    }


type Log
    = DomContentLoadedTwice ReadyState
    | LoadedTwice ReadyState
    | ListeningForOneClick
    | GotOneClick
    | ListeningForKeys Bool
    | RespondedViaMessage
    | RespondedViaTask
    | TestingRemove


type Action
    = NoOp
    | Write Log
    | ListenForOneClick
    | ListenForKeys Bool
    | SetClickListener (Maybe Listener)
    | TestRemove


init : (Model, Effects Action)
init =
    let
        action1 =
            Effects.task <|
                Task.map
                    (Write << DomContentLoadedTwice)
                    getReadyState `Task.andThen` (\state ->
                        Task.map (always state) <|
                            domContentLoaded `Task.andThen`
                            always domContentLoaded
                    )

        action2 =
            Effects.task <|
                Task.map
                    (Write << LoadedTwice)
                    getReadyState `Task.andThen` (\state ->
                        Task.map (always state) <|
                            loaded `Task.andThen`
                            always loaded
                    )
    in
        ( Model [] Nothing
        , Effects.batch 
            [ action1
            , action2
            ]
        )


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            ( model, Effects.none )

        Write entry ->
            ( { model | log <- entry :: model.log }
            , Effects.none
            )

        ListenForOneClick ->
            ( { model | log <- ListeningForOneClick :: model.log }
            , Effects.task <|
                Task.map
                    (always (Write GotOneClick))
                    (once "click")
            )

        TestRemove ->
            ( { model | log <- TestingRemove :: model.log }
            , Effects.task <|
                Task.map (always NoOp) <|
                    on "click" (\event listener ->
                        [ remove
                        , performTask <|
                            Signal.send mailbox.address <|
                                Write RespondedViaTask
                        ]
                    )
            )

        ListenForKeys start ->
            case (start, model.clickListener) of
                (True, Nothing) ->
                    ( { model | log <- ListeningForKeys True :: model.log }
                    , Effects.task <|
                        Task.map
                            (SetClickListener << Just) <|
                            on "keypress" (\event listener ->
                                [ stopPropagation
                                , stopImmediatePropagation
                                , preventDefault
                                , performTask <|
                                    Signal.send mailbox.address <|
                                        Write RespondedViaTask

                                , send <|
                                    Signal.message mailbox.address <|
                                        Write RespondedViaMessage
                                ]
                            )
                    )

                (False, Just listener) ->
                    ( { model | log <- ListeningForKeys False :: model.log }
                    , Effects.task <|
                        Task.map
                            (always (SetClickListener Nothing))
                            (removeListener listener)
                    )

                (_, _) ->
                    ( model, Effects.none )

        SetClickListener listener ->
            ( { model | clickListener <- listener }
            , Effects.none
            )


view : Address Action -> Model -> Html
view address model =
    div 
        [ style
            [ ("padding", "8px")
            ]
        ]
        [ button
            [ onClick address ListenForOneClick
            , id "listen-for-one-click"
            ]
            [ text "Listen for one click" ]
        , button
            [ onClick address (ListenForKeys True)
            , id "listen-for-keys-true"
            ]
            [ text "Listen for keyup" ]
        , button
            [ onClick address (ListenForKeys False)
            , id "listen-for-keys-false"
            ]
            [ text "Stop listening for keyup" ]
        , button
            [ onClick address TestRemove
            , id "test-remove-response"
            ]
            [ text "Listen for click and remove" ]
        , div []
            [ input [] []
            ]
        , h4 [] [ text "Log (most recent first)" ]
        , div
            [ id "log" ]
            <|
            List.map (\entry ->
                p [] [ text (toString entry) ]
            ) model.log
        ]
