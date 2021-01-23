module Elm.Function.Body exposing (Body, parse)

import Parser exposing (..)


type alias Body =
    List Part


type Part
    = Text String
    | Parameter String


parse : String -> Result (List DeadEnd) Body
parse =
    run parser


parser : Parser Body
parser =
    let
        step parts =
            oneOf
                [ end |> map (\_ -> Done (List.reverse parts))
                , oneOf [ parameter, text ] |> map (\part -> Loop (part :: parts))
                ]
    in
    loop [] step


text : Parser Part
text =
    chompUntilEndOr "{{"
        |> getChompedString
        |> map Text


parameter : Parser Part
parameter =
    succeed (String.trim >> Parameter)
        |. symbol "{{"
        |= (getChompedString <| chompUntil "}}")
        |. symbol "}}"
