module Components.Editor exposing (Model, MsgIn(..), MsgOut(..), component)

import Framework.Actor exposing (Component, Pid)
import Framework.Template.Components exposing (Components)
import Framework.Template.Markdown as MarkdownTemplate exposing (MarkdownTemplate)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)


type alias Model =
    { input : String
    , error : Maybe String
    }


type MsgIn
    = OnInput String


type MsgOut appActors
    = UpdateMarkdownTemplate (MarkdownTemplate appActors)


component : Components appActors -> Component String Model MsgIn (MsgOut appActors) (Html msg) msg
component components =
    { init = init components
    , update = update components
    , subscriptions = always Sub.none
    , view = view
    }


init : Components appActors -> ( a, String ) -> ( Model, List (MsgOut appActors), Cmd MsgIn )
init components ( _, defaultInput ) =
    update
        components
        (OnInput defaultInput)
        { input = ""
        , error = Nothing
        }


update : Components appActors -> MsgIn -> Model -> ( Model, List (MsgOut appActors), Cmd MsgIn )
update components msgIn model =
    case msgIn of
        OnInput input ->
            case MarkdownTemplate.parse components input of
                Err error ->
                    ( { model | input = input, error = Just error }
                    , []
                    , Cmd.none
                    )

                Ok markdownTemplate ->
                    ( { model | input = input, error = Nothing }
                    , [ UpdateMarkdownTemplate (Debug.log "??" markdownTemplate) ]
                    , Cmd.none
                    )


view : (MsgIn -> msg) -> Model -> (Pid -> Maybe (Html msg)) -> Html msg
view toSelf model _ =
    div [ class "Editor" ]
        [ div [ class "form-group" ]
            [ label [ for "editor_input" ]
                [ text "Markdown Template" ]
            , textarea
                [ class "form-control"
                , classList [ ( " is-invalid", model.error /= Nothing ) ]
                , id "editor_input"
                , rows 30
                , OnInput >> toSelf |> onInput
                ]
                [ Html.text model.input
                ]
            ]
        ]
