module WindowExample where

import WebAPI.Window exposing (alert, confirm, prompt)
import WebAPI.Location exposing (reload)

import Effects exposing (Effects, Never)
import StartApp exposing (App)
import Task exposing (Task, toResult)
import Html exposing (Html, h4, div, text, button)
import Html.Events exposing (onClick)
import Signal exposing (Signal, Address)


app : App Model
app =
    StartApp.start
        { init = init
        , update = update
        , view = view
        , inputs = []
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
    | Reload Bool
    | HandleReload (Result String ())


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        HandleReload result ->
            ( "Reloaded (but if this stays, then that's an error)"
            , Effects.none
            )

        Reload forceServer ->
            ( "About to reload"
            , reload forceServer |>
                toResult |>
                    Task.map HandleReload |>
                        Effects.task
            )

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


view : Address Action -> Model -> Html
view address model =
    div []
        [ button
            [ onClick address (ShowAlert "Hello world!") ]
            [ text "WebAPI.Window.alert" ]
        , button
            [ onClick address (ShowConfirm "Do you agree?") ]
            [ text "WebAPI.Window.confirm" ]
        , button
            [ onClick address (ShowPrompt "What is your favourite colour?" "Blue") ]
            [ text "WebAPI.Window.prompt" ]
        , button
            [ onClick address (Reload True) ]
            [ text "WebAPI.Location.reload True" ]
        , button
            [ onClick address (Reload True) ]
            [ text "WebAPI.Location.reload False" ]
        , h4 [] [ text "Message" ]
        , div [] [ text model ]
        ]

