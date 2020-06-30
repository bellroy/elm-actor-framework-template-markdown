module Framework.Template.Markdown exposing
    ( MarkdownTemplate
    , blank, parse, fromNodes
    , toNodes
    , getActorsToSpawn
    )

{-|

@docs MarkdownTemplate


# Creation

@docs blank, parse, fromNodes


# Rendering

@docs toNodes


# Utility

@docs getActorsToSpawn

-}

import Framework.Template exposing (ActorElement, Node)
import Framework.Template.Components exposing (Components)
import Framework.Template.Markdown.Internal.MarkdownTemplate as MarkdownTemplate
import Framework.Template.Markdown.Internal.Parser as Parser


{-| Your parsed template that originated from a string containing valid Html
-}
type alias MarkdownTemplate appActors =
    MarkdownTemplate.MarkdownTemplate appActors


{-| An empty, blank MarkdownTemplate
-}
blank : MarkdownTemplate appActors
blank =
    MarkdownTemplate.empty


{-| Parse a string containing valid Html into an MarkdownTemplate

Add Components to replace Html Elements with your Actors based on their
nodeNames. (e.g. `<my-actor></my-actor>`)

-}
parse :
    Components appActors
    -> String
    -> Result String (MarkdownTemplate appActors)
parse =
    Parser.parse


{-| Turn a list of Nodes into an MarkdownTemplate

This could be useful for when you use your own Html Parser.

-}
fromNodes : List (Node appActors) -> MarkdownTemplate appActors
fromNodes =
    MarkdownTemplate.fromNodes


{-| Turn a MarkdownTemplate into a list of Nodes

This could be useful for when you want to write or use another method of
rendering the template in question.

-}
toNodes : MarkdownTemplate appActors -> List (Node appActors)
toNodes =
    MarkdownTemplate.toNodes


{-| Get the actor, reference and original complete node from a template that
are meant to be spawned.

The String is a reference that can be used on the render function in combination
with a Pid to render the Actors output.

-}
getActorsToSpawn :
    MarkdownTemplate appActors
    ->
        List
            { actor : appActors
            , reference : String
            , actorElement : ActorElement appActors
            }
getActorsToSpawn =
    MarkdownTemplate.getActorsToSpawn
