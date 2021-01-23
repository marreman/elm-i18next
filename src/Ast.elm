module Ast exposing (..)

import Dict exposing (Dict)
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Parser as P exposing ((|.), (|=), Parser)


type Ast
    = Group (Dict String Ast)
    | Value (List Text)


type Text
    = Static String
    | Parameter String


decodeValue : E.Value -> Result D.Error Ast
decodeValue =
    D.decodeValue decoder


decoder : Decoder Ast
decoder =
    D.oneOf
        [ D.dict (D.lazy (\_ -> decoder)) |> D.map Group
        , D.string |> D.andThen parseText |> D.map Value
        ]


parseText : String -> Decoder (List Text)
parseText string =
    case P.run parser string of
        Ok parameters ->
            D.succeed parameters

        Err _ ->
            D.fail "failed to parse parameters"


parser : Parser (List Text)
parser =
    let
        step parts =
            P.oneOf
                [ P.end |> P.map (\_ -> P.Done (List.reverse parts))
                , P.oneOf [ parameter, static ] |> P.map (\part -> P.Loop (part :: parts))
                ]

        static =
            P.chompUntilEndOr "{{"
                |> P.getChompedString
                |> P.map Static

        parameter =
            P.succeed (String.trim >> Parameter)
                |. P.symbol "{{"
                |= (P.getChompedString <| P.chompUntil "}}")
                |. P.symbol "}}"
    in
    P.loop [] step
