module Components.Layout exposing (Model, MsgIn(..), MsgOut(..), component)

import Dict exposing (Dict)
import Framework.Actor exposing (Component, Pid)
import Framework.Template exposing (ActorElement)
import Framework.Template.Markdown as MarkdownTemplate exposing (MarkdownTemplate)
import Framework.Template.Html as HtmlTemplate 

import Html exposing (Html)


type alias Model appActors =
    { instances : Dict String Pid
    , markdownTemplate : MarkdownTemplate appActors
    }


type MsgIn appActors
    = OnSpawnedActor String Pid
    | UpdateMarkdownTemplate (MarkdownTemplate appActors)


type MsgOut appActors
    = StopProcesses (List Pid)
    | SpawnActors (List ( appActors, String, ActorElement appActors ))


component : Component (MarkdownTemplate appActors) (Model appActors) (MsgIn appActors) (MsgOut appActors) (Html msg) msg
component =
    { init = init
    , update = update
    , subscriptions = always Sub.none
    , view = view
    }


init : ( a, MarkdownTemplate appActors ) -> ( Model appActors, List (MsgOut appActors), Cmd (MsgIn appActors) )
init ( _, markdownTemplate ) =
    { instances = Dict.empty
    , markdownTemplate = MarkdownTemplate.blank
    }
        |> update (UpdateMarkdownTemplate markdownTemplate)


update : MsgIn appActors -> Model appActors -> ( Model appActors, List (MsgOut appActors), Cmd (MsgIn appActors) )
update msgIn model =
    case msgIn of
        UpdateMarkdownTemplate markdownTemplate ->
            ( { instances = Dict.empty
              , markdownTemplate = markdownTemplate
              }
            , [ model.instances
                    |> Dict.toList
                    |> List.map Tuple.second
                    |> StopProcesses
              , MarkdownTemplate.getActorsToSpawn
                    markdownTemplate
                    |> List.map
                        (\{ actor, reference, actorElement } ->
                            ( actor, reference, actorElement )
                        )
                    |> SpawnActors
              ]
            , Cmd.none
            )

        OnSpawnedActor id pid ->
            ( { model
                | instances = Dict.insert id pid model.instances
              }
            , []
            , Cmd.none
            )


view : a -> Model appActors -> (Pid -> Maybe (Html msg)) -> Html msg
view _ { instances, markdownTemplate } renderPid =
    MarkdownTemplate.toNodes markdownTemplate
        |> HtmlTemplate.fromNodes
        |> HtmlTemplate.render instances renderPid  
        |> Html.div []
