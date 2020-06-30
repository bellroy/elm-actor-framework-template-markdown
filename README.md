# Elm Actor Framework - Template - Markdown

This package is as an extension of the [Elm Actor Framework](https://github.com/tricycle/elm-actor-framework) [Package](https://package.elm-lang.org/packages/tricycle/elm-actor-framework/latest).

[Demo](https://tricycle.github.io/elm-actor-framework-markdown)

Turn your markdown templates into Html or any other output enriched by your Actors.

```elm
import Framework.Template.Markdown exposing (MarkdownTemplate, blank, parse)


type Actors
    = Editor
    | Layout
    | Counter


components : Components Actors
components =
    Components.fromList
        [ Component.make
            { actor = Counter
            , nodeName = "counter-component"
            }
        , Component.make
            { actor = Counter
            , nodeName = "COUNTER"
            }
        ]


template : String
template =
    """
## A Markdown Example

Lorem ipsum dolor sit amet ...

- [x] list item
- [ ] more dummy content
 
Render an actor here!

<counter-component steps="10" value="10" ></counter-component> 

And another one:

<!COUNTER 100:25 >

"""


markdownTemplate : MarkdownTemplate Actors
markdownTemplate =
    parse components template
        |> Result.withDefault blank
```

## Templates

Actors make up ideal components that can be used on a template.

This module uses a shared type from the `Elm Actor Framework -Templates` package.
The goal of these packages is to be able to provide different parsers and renderers.

- [Elm Actor Framework - Templates](https://github.com/tricycle/elm-actor-framework-template)
  - [Demo](https://tricycle.github.io/elm-actor-framework)
- [Elm Actor Framework - Templates - Html](https://github.com/tricycle/elm-actor-framework-template-html)
  - [Demo](https://tricycle.github.io/elm-actor-framework-html)
  - **Parse** Html Template (Using [`hecrj/html-parser`](https://github.com/hecrj/html-parser))
  - **Render** Html (Using [`elm/html`](https://github.com/elm/html))
- [Elm Actor Framework - Templates - Markdown](https://github.com/tricycle/elm-actor-framework-template-markdown)
  - [Demo](https://tricycle.github.io/elm-actor-framework-mardown)
  - **Parse** Markdown (Using [dillonkearns/elm-markdown](https://github.com/dillonkearns/elm-markdown))
