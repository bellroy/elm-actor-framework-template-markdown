module Actors.Layout exposing (actor)

import Actors exposing (Actors(..))
import AppFlags exposing (AppFlags(..))
import Components.Layout as Layout exposing (MsgIn(..), MsgOut(..))
import Framework.Actor as Actor exposing (Actor)
import Framework.Message as Message
import Framework.Template as Template
import Framework.Template.Markdown as MarkdownTemplate
import Html exposing (Html)
import Model exposing (Model(..))
import Msg exposing (AppMsg(..), Msg)


actor : Actor AppFlags (Layout.Model Actors) Model (Html Msg) Msg
actor =
    Layout.component
        |> Actor.altInit
            (\init ( pid, appFlags ) ->
                case appFlags of
                    LayoutFlags template ->
                        init ( pid, template )

                    _ ->
                        init ( pid, MarkdownTemplate.blank )
            )
        |> Actor.fromComponent
            { toAppModel = LayoutModel
            , toAppMsg = LayoutMsg
            , fromAppMsg =
                \msg ->
                    case msg of
                        LayoutMsg msgIn ->
                            Just msgIn

                        _ ->
                            Nothing
            , onMsgOut =
                \{ self, msgOut } ->
                    case msgOut of
                        StopProcesses pids ->
                            List.map Message.stopProcess pids
                                |> Message.batch

                        SpawnActors actorsAndReferences ->
                            actorsAndReferences
                                |> List.map
                                    (\( actorToSpawn, reference, Template.ActorElement _ _ _ attributes children ) ->
                                        let
                                            flags =
                                                case ( actorToSpawn, children ) of
                                                    ( Counter, [ Template.Text text ] ) ->
                                                        case String.trim text |> String.split ":" |> List.filterMap String.toInt of
                                                            [ value ] ->
                                                                CounterFlags { value = value, steps = 1 }

                                                            [ value, steps ] ->
                                                                CounterFlags { value = value, steps = steps }

                                                            _ ->
                                                                CounterFlags { value = 0, steps = 1 }

                                                    ( Counter, _ ) ->
                                                        List.foldl
                                                            (\( key, value ) r ->
                                                                case ( key, String.toInt value ) of
                                                                    ( "value", Just int ) ->
                                                                        { r | value = int }

                                                                    ( "steps", Just int ) ->
                                                                        { r | steps = int }

                                                                    _ ->
                                                                        r
                                                            )
                                                            { value = 0, steps = 1 }
                                                            attributes
                                                            |> CounterFlags

                                                    ( Layout, _ ) ->
                                                        LayoutFlags (MarkdownTemplate.fromNodes children)

                                                    _ ->
                                                        Empty
                                        in
                                        Message.spawn
                                            flags
                                            actorToSpawn
                                            (OnSpawnedActor reference
                                                >> LayoutMsg
                                                >> Message.sendToPid self
                                            )
                                    )
                                |> Message.batch
            }
