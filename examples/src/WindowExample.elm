module WindowExample where

import Effects exposing (Effects, Never)
import StartApp exposing (App)
import Task exposing (Task, toResult)
import Html exposing (Html, h4, div, text, button)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)
import Signal exposing (Signal, Address)

import WebAPI.Event exposing (Listener, removeListener)
import WebAPI.Window exposing (alert, confirm, prompt, isOnline, confirmUnload)
import WebAPI.Event.BeforeUnload exposing (BeforeUnloadEvent)


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


type alias Model =
    { message : String
    , confirmUnloadListener : Maybe (Listener BeforeUnloadEvent)
    }


init : (Model, Effects Action)
init = (Model "" Nothing, Effects.none)


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
    | ConfirmUnload Bool
    | SetConfirmUnloadListener (Maybe (Listener BeforeUnloadEvent))


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
            ( { model | message = "Got alert response" }
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
            let
                message =
                    case result of
                        Ok _ -> "Pressed OK"
                        Err _ -> "Pressed cancel"
            in
                ( { model | message = message }
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
            let
                message =
                    case result of
                        Ok response -> "Got response: " ++ response
                        Err _ -> "User canceled."

            in
                ( { model | message = message }
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
             let
                 message =
                    case result of
                        Ok online ->
                            "Am I online? " ++ (toString online)

                        Err _ ->
                            "Got err ... shouldn't happen"

            in
                ( { model | message = message }
                , Effects.none
                )

        HandleOnlineSignal online ->
            ( { model |
                    message =
                        if online
                            then "I'm online now"
                            else "I'm offline now"
              }
            , Effects.none
            )

        ConfirmUnload enable ->
            ( model
            , case (enable, model.confirmUnloadListener) of
                (True, Nothing) ->
                    Effects.task <|
                        Task.map
                            (SetConfirmUnloadListener << Just)
                            (confirmUnload "Are you sure you want to leave?")

                (False, Just listener) ->
                    Effects.task <|
                        Task.map
                            (always (SetConfirmUnloadListener Nothing))
                            (removeListener listener)

                (_, _) ->
                    Effects.none
            )

        SetConfirmUnloadListener listener ->
            ( { model | confirmUnloadListener = listener }
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
        , button
            [ onClick address (ConfirmUnload True)
            , id "enable-confirm-unload"
            ]
            [ text "Enable confirmUnload" ]
        , button
            [ onClick address (ConfirmUnload False)
            , id "disable-confirm-unload"
            ]
            [ text "Disable confirmUnload" ]
        , h4 [] [ text "Message" ]
        , div [ id "message" ] [ text model.message ]
        ]

