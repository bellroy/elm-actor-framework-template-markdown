module Framework.Template.Markdown.Internal.MarkdownTemplate exposing
    ( MarkdownTemplate
    , empty
    , fromNodes
    , getActorsToSpawn
    , toNodes
    )

import Framework.Template as Template exposing (ActorElement(..), Node(..))


type MarkdownTemplate appActors
    = MarkdownTemplate (List (Node appActors))


empty : MarkdownTemplate appActors
empty =
    fromNodes []


fromNodes : List (Node appActors) -> MarkdownTemplate appActors
fromNodes =
    MarkdownTemplate


toNodes : MarkdownTemplate appActors -> List (Node appActors)
toNodes (MarkdownTemplate nodes) =
    nodes


getActorsToSpawn :
    MarkdownTemplate appActors
    ->
        List
            { actor : appActors
            , reference : String
            , actorElement : ActorElement appActors
            }
getActorsToSpawn =
    toNodes >> Template.getActorsToSpawn
