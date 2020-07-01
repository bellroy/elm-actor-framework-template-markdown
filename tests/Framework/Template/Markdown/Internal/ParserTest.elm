module Framework.Template.Markdown.Internal.ParserTest exposing (suite)

import Expect
import Framework.Template exposing (ActorElement(..), Node(..))
import Framework.Template.Component as Component
import Framework.Template.Components as Components
import Framework.Template.Markdown.Internal.MarkdownTemplate as MarkdownTemplate
import Framework.Template.Markdown.Internal.Parser as Parser
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Parser"
        [ test_parse
        ]


input : String
input =
    """
## Hello World

Some **random** _text_

---

<some-actor></some-actor>

[link](https://www.example.com)

- a list item
- [x] ticked list item

3. numbered list item
4. another numbered list item

```elm
example: String
example = "Code Example"
```

"""


test_parse : Test
test_parse =
    describe "Parse"
        [ test "template  1" <|
            \_ ->
                let
                    components =
                        Components.fromList
                            [ Component.make { nodeName = "some-actor", actor = "someActor" }
                                |> Component.setDefaultAttributes [ ( "class", "ClassName" ) ]
                            ]

                    output =
                        [ Element "h2" [] [ Text "Hello World" ]
                        , Element "p"
                            []
                            [ Text "Some "
                            , Element "strong" [] [ Text "random" ]
                            , Text " "
                            , Element "em" [] [ Text "text" ]
                            ]
                        , Element "hr" [] []
                        , Actor
                            (ActorElement "someActor"
                                "some-actor"
                                "aa92325a8f7c35213d56060abd68f97b"
                                [ ( "class", "ClassName" )
                                ]
                                []
                            )
                        , Element "p"
                            []
                            [ Element "a"
                                [ ( "href", "https://www.example.com" ) ]
                                [ Text "link"
                                ]
                            ]
                        , Element "ul"
                            []
                            [ Element "li" [] [ Text "a list item" ]
                            , Element "li"
                                []
                                [ Element "input"
                                    [ ( "type", "checkbox" )
                                    , ( "disabled", "true" )
                                    , ( "checked", "checked" )
                                    ]
                                    []
                                , Text "ticked list item"
                                ]
                            ]
                        , Element "ol"
                            [ ( "start", "3" ) ]
                            [ Element "li" [] [ Text "numbered list item" ]
                            , Element "li" [] [ Text "another numbered list item" ]
                            ]
                        , Element "code"
                            [ ( "data-language", "elm" ) ]
                            [ Text "example: String\nexample = \"Code Example\""
                            ]
                        ]
                            |> MarkdownTemplate.fromNodes
                in
                Expect.equal (Parser.parse components input)
                    (Ok output)
        ]
