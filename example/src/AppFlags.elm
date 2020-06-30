module AppFlags exposing (AppFlags(..))

import Actors exposing (Actors)
import Framework.Template.Markdown exposing (MarkdownTemplate)


type AppFlags
    = CounterFlags { value: Int, steps: Int }
    | LayoutFlags (MarkdownTemplate Actors)
    | EditorFlags String
    | Empty
