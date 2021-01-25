module Text exposing (..)

import Dict exposing (Dict)
import Json.Decode as D
import Parser as P exposing ((|.), (|=))


type alias Path =
    List String


type alias Module =
    Dict String (List Text)


type Text
    = Static String
    | Parameter String


type Token
    = String_ String
    | Value_ D.Value


fromJson : D.Value -> Dict Path Module
fromJson value =
    decode [ "Text" ] value Dict.empty


decode : Path -> D.Value -> Dict Path Module -> Dict Path Module
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


combine : Path -> Dict Path Module -> ( Module, Dict String D.Value ) -> Dict Path Module
combine path ast ( strings, values ) =
    Dict.foldl
        (\name -> decode (name :: path))
        (Dict.insert path strings ast)
        values



-- PARSING


parseText : String -> String -> List Text
parseText _ string =
    P.run phraseParser string
        |> Result.withDefault []


phraseParser : P.Parser (List Text)
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
                |> P.map Static

        parameter =
            P.succeed (String.trim >> Parameter)
                |. P.symbol "{{"
                |= (P.getChompedString <| P.chompUntil "}}")
                |. P.symbol "}}"
    in
    P.loop [] step
