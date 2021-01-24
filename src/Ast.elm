module Ast exposing (..)

import Dict exposing (Dict)
import Json.Decode as D exposing (Decoder)
import Parser as P exposing ((|.), (|=))


type alias Ast =
    Dict Path (Dict String String)


type alias Path =
    List String


type Token
    = String_ String
    | Value_ D.Value


fromJson : D.Value -> Ast
fromJson value =
    decode [ "Text" ] value Dict.empty


decode : Path -> D.Value -> Ast -> Ast
decode name value ast =
    D.decodeValue decoder value
        |> Result.map (partition >> combine name ast)
        |> Result.withDefault Dict.empty


decoder : D.Decoder (Dict String Token)
decoder =
    D.dict <|
        D.oneOf
            [ D.map String_ D.string
            , D.map Value_ D.value
            ]


partition : Dict String Token -> ( Dict String String, Dict String D.Value )
partition =
    Dict.foldl
        (\name token ( strings, values ) ->
            case token of
                String_ string ->
                    ( Dict.insert name string strings, values )

                Value_ value ->
                    ( strings, Dict.insert name value values )
        )
        ( Dict.empty, Dict.empty )


combine : Path -> Ast -> ( Dict String String, Dict String D.Value ) -> Ast
combine path ast ( strings, values ) =
    Dict.foldl
        (\name -> decode (name :: path))
        (Dict.insert path strings ast)
        values



-- PARSING


type Part
    = Text String
    | Parameter String


parseText : String -> Decoder (List Part)
parseText string =
    if String.contains "{{" string then
        case P.run parser string of
            Ok parameters ->
                D.succeed parameters

            Err _ ->
                D.fail "failed to parse parameters"

    else
        D.fail "not a function"


parser : P.Parser (List Part)
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
                |> P.map Text

        parameter =
            P.succeed (String.trim >> Parameter)
                |. P.symbol "{{"
                |= (P.getChompedString <| P.chompUntil "}}")
                |. P.symbol "}}"
    in
    P.loop [] step
