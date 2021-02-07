module ExampleUsage exposing (..)

import Text
import Html


view : Html msg
view = 
    Html.div []
        [ Html.h1 [] [ Html.text Text.helloWorld ]
        , Html.p [] <| Text.greeting text { name = "Martin" }
        ]
