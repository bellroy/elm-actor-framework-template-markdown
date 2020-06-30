module Actors exposing (Actors(..), components)

import Framework.Template.Component as Component
import Framework.Template.Components as Components exposing (Components)


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
        , Component.make
            { actor = Layout
            , nodeName = "layout-component"
            }
        ]
