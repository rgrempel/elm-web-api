module WindowExample where

import Effects exposing (Effects, Never)
import StartApp exposing (App)
import Task exposing (Task, toResult)
import Html exposing (Html, h4, div, text, button)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)
import Signal exposing (Signal, Address)

import WebAPI.Window exposing (alert, confirm, prompt, isOnline)


app : App Model
app =
    StartApp.start
        { init = init
        , update = update
        , view = view
        , inputs =
            [ Signal.map HandleOnlineSignal WebAPI.Window.online
            ]
        }


main : Signal Html
main = app.html


port tasks : Signal (Task.Task Never ())
port tasks = app.tasks


type alias Model = String


init : (Model, Effects Action)
init = ("", Effects.none)


type Action
    = ShowAlert String
    | HandleAlertResponse
    | ShowConfirm String
    | HandleConfirmResponse (Result () ())
    | ShowPrompt String String
    | HandlePromptResponse (Result () String)
    | CheckOnline
    | HandleOnlineResponse (Result () Bool)
    | HandleOnlineSignal Bool


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        ShowAlert message ->
            ( model
            , alert message |>
                Task.map (always HandleAlertResponse) |>
                    Effects.task
            )

        HandleAlertResponse ->
            ( "Got alert response"
            , Effects.none
            )

        ShowConfirm message ->
            ( model
            , confirm message |>
                toResult |>
                    Task.map HandleConfirmResponse |>
                        Effects.task
            )

        HandleConfirmResponse result ->
            ( case result of
                Ok _ ->
                    "Pressed OK"

                Err _ ->
                    "Pressed cancel"

            , Effects.none
            )

        ShowPrompt message default ->
            ( model
            , prompt message default |>
                toResult |>
                    Task.map HandlePromptResponse |>
                        Effects.task
            )

        HandlePromptResponse result ->
            ( case result of
                Ok response ->
                    "Got response: " ++ response

                Err _ ->
                    "User canceled."

            , Effects.none
            )

        CheckOnline ->
            ( model
            , isOnline |>
                toResult |>
                    Task.map HandleOnlineResponse |>
                        Effects.task
            )

        HandleOnlineResponse result ->
            ( case result of
                Ok online ->
                    "Am I online? " ++ (toString online)

                Err _ ->
                    "Got err ... shouldn't happen"

            , Effects.none
            )

        HandleOnlineSignal online ->
            ( if online
                then "I'm online now"
                else "I'm offline now"

            , Effects.none
            )


view : Address Action -> Model -> Html
view address model =
    div []
        [ button
            [ onClick address (ShowAlert "Hello world!")
            , id "alert-button"
            ]
            [ text "WebAPI.Window.alert" ]
        , button
            [ onClick address (ShowConfirm "Do you agree?")
            , id "confirm-button"
            ]
            [ text "WebAPI.Window.confirm" ]
        , button
            [ onClick address (ShowPrompt "What is your favourite colour?" "Blue")
            , id "prompt-button"
            ]
            [ text "WebAPI.Window.prompt" ]
        , button
            [ onClick address CheckOnline
            , id "online-button"
            ]
            [ text "WebAPI.Window.isOnline" ]
        , h4 [] [ text "Message" ]
        , div [ id "message" ] [ text model ]
        ]

