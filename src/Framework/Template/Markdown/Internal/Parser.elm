module Framework.Template.Markdown.Internal.Parser exposing (parse)

import Dict
import Framework.Template as Template
import Framework.Template.Component as Component
import Framework.Template.Components as Components exposing (Components)
import Framework.Template.Markdown.Internal.MarkdownTemplate as MarkdownTemplate exposing (MarkdownTemplate)
import MD5
import Markdown.Block as Block exposing (..)
import Markdown.Parser as MarkdownParser


parse :
    Components appActors
    -> String
    -> Result String (MarkdownTemplate appActors)
parse components =
    MarkdownParser.parse
        >> Result.mapError (List.map MarkdownParser.deadEndToString >> String.join ",")
        >> Result.map
            (parserBlocksToTemplateNodes components
                >> MarkdownTemplate.fromNodes
            )


parserBlocksToTemplateNodes :
    Components appActors
    -> List Block.Block
    -> List (Template.Node appActors)
parserBlocksToTemplateNodes components =
    List.filterMap (parserBlockToTemplateNode components)


parserBlockToTemplateNode :
    Components appActors
    -> Block.Block
    -> Maybe (Template.Node appActors)
parserBlockToTemplateNode components block =
    case block of
        Block.HtmlBlock html ->
            parserBlockHtmlToTemplateNode components html

        Block.UnorderedList listItems ->
            parserBlockUnorderedListToTemplateNode components listItems

        Block.OrderedList index listOfListOfInline ->
            -- @todo
            Nothing

        Block.BlockQuote children ->
            parserBlockQuoteToTemplateNode components children

        Block.Heading headingLevel children ->
            parserBlockHeadingToTemplateNode components headingLevel children

        Block.Paragraph children ->
            parserBlockParagraphToTemplateNode components children

        Block.Table _ _ ->
            -- @todo
            Nothing

        Block.CodeBlock { body, language } ->
            parserBlockCodeblockToTemplateNode body language
                |> Just

        Block.ThematicBreak ->
            Nothing


parserBlockCodeblockToTemplateNode :
    String
    -> Maybe String
    -> Template.Node appActors
parserBlockCodeblockToTemplateNode body maybeLanguage =
    Template.Element "code"
        [ ( "data-language"
          , Maybe.withDefault "" maybeLanguage
          )
        ]
        [ Template.Text body
        ]


parserBlockParagraphToTemplateNode :
    Components appActors
    -> List Block.Inline
    -> Maybe (Template.Node appActors)
parserBlockParagraphToTemplateNode components =
    List.filterMap (parserBlockInlineToTemplateNode components)
        >> wrapIfNotEmpty "p"


parserBlockHeadingToTemplateNode :
    Components appActors
    -> Block.HeadingLevel
    -> List Block.Inline
    -> Maybe (Template.Node appActors)
parserBlockHeadingToTemplateNode components headingLevel =
    let
        nodeName =
            Block.headingLevelToInt headingLevel
                |> String.fromInt
                |> (++) "h"
    in
    List.filterMap (parserBlockInlineToTemplateNode components)
        >> wrapIfNotEmpty nodeName


parserBlockQuoteToTemplateNode :
    Components appActors
    -> List Block.Block
    -> Maybe (Template.Node appActors)
parserBlockQuoteToTemplateNode components =
    List.filterMap (parserBlockToTemplateNode components)
        >> wrapIfNotEmpty "blockquote"


parserBlockUnorderedListToTemplateNode :
    Components appActors
    -> List (Block.ListItem Block.Inline)
    -> Maybe (Template.Node appActors)
parserBlockUnorderedListToTemplateNode components =
    List.map (parserBlockListItemToTemplateNode components)
        >> wrapIfNotEmpty "ul"


parserBlockListItemToTemplateNode :
    Components appActors
    -> Block.ListItem Block.Inline
    -> Template.Node appActors
parserBlockListItemToTemplateNode components (Block.ListItem task children) =
    let
        input =
            case task of
                Block.NoTask ->
                    Nothing

                Block.IncompleteTask ->
                    Just <| Template.Element "input" [ ( "type", "checkbox" ) ] []

                Block.CompletedTask ->
                    Just <| Template.Element "input" [ ( "type", "checkbox" ), ( "checked", "checked" ) ] []

        parsedChildren =
            List.map (parserBlockInlineToTemplateNode components) children

        filteredChildren =
            List.filterMap identity (input :: parsedChildren)
    in
    Template.Element "li" [] filteredChildren


parserBlockInlineToTemplateNode :
    Components appActors
    -> Block.Inline
    -> Maybe (Template.Node appActors)
parserBlockInlineToTemplateNode components inline =
    case inline of
        Block.HtmlInline html ->
            parserBlockHtmlToTemplateNode components html

        Block.Link href maybeTitle children ->
            List.filterMap (parserBlockInlineToTemplateNode components) children
                |> (::) (Template.Text (Maybe.withDefault href maybeTitle))
                |> Template.Element "a" [ ( "href", href ) ]
                |> Just

        Block.Image src maybeTitle _ ->
            Template.Element "img"
                [ ( "src", src )
                , ( "title", maybeTitle |> Maybe.withDefault "" )
                ]
                []
                |> Just

        Block.Emphasis children ->
            List.filterMap (parserBlockInlineToTemplateNode components) children
                |> Template.Element "em" []
                |> Just

        Block.Strong children ->
            List.filterMap (parserBlockInlineToTemplateNode components) children
                |> Template.Element "strong" []
                |> Just

        Block.CodeSpan text ->
            Template.Element "code"
                []
                [ Template.Text text ]
                |> Just

        Block.Text text ->
            Template.Text text
                |> Just

        Block.HardLineBreak ->
            Nothing


parserBlockHtmlToTemplateNode :
    Components appActors
    -> Block.Html Block.Block
    -> Maybe (Template.Node appActors)
parserBlockHtmlToTemplateNode components html =
    case html of
        Block.HtmlElement nodeName parserAttributes children ->
            let
                attributes =
                    parserAttributesToAttributes parserAttributes
            in
            case Components.getByNodeName nodeName components of
                Nothing ->
                    parserBlocksToTemplateNodes components children
                        |> Template.Element nodeName attributes
                        |> Just

                Just component ->
                    Template.ActorElement
                        (Component.toActor component)
                        nodeName
                        (attributesToString attributes
                            |> (++) nodeName
                            |> MD5.hex
                        )
                        (Component.toDefaultAttributes component
                            |> mergeAttributes attributes
                        )
                        (parserBlocksToTemplateNodes components children)
                        |> Template.Actor
                        |> Just

        Block.HtmlComment _ ->
            Nothing

        Block.ProcessingInstruction _ ->
            Nothing

        Block.HtmlDeclaration nodeName rest ->
            Components.getByNodeName nodeName components
                |> Maybe.map
                    (\component ->
                        Template.ActorElement
                            (Component.toActor component)
                            nodeName
                            (MD5.hex (nodeName ++ rest))
                            (Component.toDefaultAttributes component)
                            [ Template.Text rest
                            ]
                            |> Template.Actor
                    )

        Block.Cdata _ ->
            Nothing


parserAttributesToAttributes :
    List Block.HtmlAttribute
    -> List ( String, String )
parserAttributesToAttributes =
    List.map (\{ name, value } -> ( name, value ))


mergeAttributes :
    List ( String, String )
    -> List ( String, String )
    -> List ( String, String )
mergeAttributes a b =
    Dict.union (Dict.fromList a) (Dict.fromList b)
        |> Dict.toList


attributesToString : List ( String, String ) -> String
attributesToString =
    List.map (\( a, b ) -> a ++ "::" ++ b)
        >> String.join "%%"


wrapIfNotEmpty :
    String
    -> List (Template.Node appActors)
    -> Maybe (Template.Node appActors)
wrapIfNotEmpty nodeName list =
    if List.length list > 0 then
        Just (Template.Element nodeName [] list)

    else
        Nothing
