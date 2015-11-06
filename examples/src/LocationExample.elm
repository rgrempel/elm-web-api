module LocationExample where

import Effects exposing (Effects, Never)
import StartApp exposing (App)
import Task exposing (Task, toResult)
import Html exposing (Html, h4, div, text, button, input)
import Html.Attributes exposing (id, type')
import Html.Events exposing (onClick, targetValue, on)
import Signal exposing (Signal, Address)

import WebAPI.Location exposing (reload, assign, replace, Source(..))


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


type alias Model =
    { message : String
    , url : String
    }


init : (Model, Effects Action)
init = (Model "Initial state" "", Effects.none)


type Action
    = Reload Source
    | HandleReload (Result String ())
    | DoAssign String
    | HandleAssign (Result String ())
    | DoReplace String
    | HandleReplace (Result String ())
    | SetUrl String


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        HandleReload result ->
            ( { model | message <- "Reloaded (but if this stays, then that's an error)" }
            , Effects.none
            )

        Reload source ->
            ( { model | message <- "About to reload" }
            , reload source |>
                toResult |>
                    Task.map HandleReload |>
                        Effects.task
            )

        SetUrl url ->
            ( { model | url <- url }
            , Effects.none
            )

        HandleAssign result ->
            let
                message =
                    case result of
                        Ok _ ->
                            "Assigned (but if this stays, then that's an error)"

                        Err err ->
                            "Got error: " ++ err
            in
                ( { model | message <- message }
                , Effects.none
                )

        DoAssign url ->
            ( { model | message <- "About to assign" }
            , assign url |>
                toResult |>
                    Task.map HandleAssign |>
                        Effects.task
            )
        
        HandleReplace result ->
            let
                message =
                    case result of
                        Ok _ ->
                            "Replaced (but if this stays, then that's an error)"

                        Err err ->
                            "Got error: " ++ err
            in
                ( { model | message <- message }
                , Effects.none
                )

        DoReplace url ->
            ( { model | message <- "About to replace" }
            , replace url |>
                toResult |>
                    Task.map HandleReplace |>
                        Effects.task
            )


view : Address Action -> Model -> Html
view address model =
    div []
        [ button
            [ id "reload-force-button" 
            , onClick address (Reload ForceServer)
            ]
            [ text "WebAPI.Location.reload ForceServer" ]
        , button
            [ id "reload-cache-button" 
            , onClick address (Reload AllowCache)
            ]
            [ text "WebAPI.Location.reload AllowCache" ]
        , div []
            [ button
                [ id "assign-button"
                , onClick address (DoAssign model.url)
                ]
                [ text "Location.assign" ]
            , button
                [ id "replace-button"
                , onClick address (DoReplace model.url)
                ]
                [ text "Location.replace" ]
            , input
                [ id "input"
                , type' "text"
                , on "input" targetValue (Signal.message address << SetUrl)
                ] []
            ]
           

        , h4 [] [ text "Message" ]
        , div [ id "message" ] [ text model.message ]
        ]

