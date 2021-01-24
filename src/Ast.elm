module Ast exposing (..)

import Dict exposing (Dict)
import Json.Decode as D
import Parser as P exposing ((|.), (|=))


type alias Ast =
    Dict Path (Dict String Text)


type alias Path =
    List String


type Text
    = StaticText String
    | ParameterizedText (List Phrase)


type Phrase
    = StaticPhrase String
    | PhraseParameter String


type Token
    = String_ String
    | Value_ D.Value


fromJson : D.Value -> Ast
fromJson value =
    decode [ "Text" ] value Dict.empty


decode : Path -> D.Value -> Ast -> Ast
decode name value ast =
    D.decodeValue decoder value
        |> Result.map (partition >> Tuple.mapFirst (Dict.map parseText) >> combine name ast)
        |> Result.withDefault Dict.empty


decoder : D.Decoder (Dict String Token)
decoder =
    D.dict <|
        D.oneOf
            [ D.string |> D.map String_
            , D.value |> D.map Value_
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


combine : Path -> Ast -> ( Dict String Text, Dict String D.Value ) -> Ast
combine path ast ( strings, values ) =
    Dict.foldl
        (\name -> decode (name :: path))
        (Dict.insert path strings ast)
        values



-- PARSING


parseText : String -> String -> Text
parseText _ string =
    if String.contains "{{" string then
        P.run phraseParser string
            |> Result.withDefault []
            |> ParameterizedText

    else
        StaticText string


phraseParser : P.Parser (List Phrase)
phraseParser =
    let
        step parts =
            P.oneOf
                [ P.end |> P.map (\_ -> P.Done (List.reverse parts))
                , P.oneOf [ parameter, static ] |> P.map (\part -> P.Loop (part :: parts))
                ]

        static =
            P.chompUntilEndOr "{{"
                |> P.getChompedString
                |> P.map StaticPhrase

        parameter =
            P.succeed (String.trim >> PhraseParameter)
                |. P.symbol "{{"
                |= (P.getChompedString <| P.chompUntil "}}")
                |. P.symbol "}}"
    in
    P.loop [] step
