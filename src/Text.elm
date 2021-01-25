module Text exposing (..)

import Dict exposing (Dict)
import Dict.Extra exposing (mapKeys)
import Json.Decode as Json
import Parser exposing ((|.), (|=))


type alias Path =
    List String


type alias Module =
    Dict String (List Text)


type Text
    = Static String
    | Parameter String


type Token
    = String_ String
    | Value_ Json.Value


fromJson : Json.Value -> Dict Path Module
fromJson value =
    run [] value Dict.empty


run : Path -> Json.Value -> Dict Path Module -> Dict Path Module
run name value modules =
    decodeTokens value
        |> groupStringsAndValues
        |> Tuple.mapFirst (Dict.map parseString)
        |> combineAndRecurse name modules
        |> mapKeys List.reverse


decodeTokens : Json.Value -> Dict String Token
decodeTokens value =
    let
        tokenDecoder =
            Json.dict <|
                Json.oneOf
                    [ Json.string |> Json.map String_
                    , Json.value |> Json.map Value_
                    ]
    in
    Json.decodeValue tokenDecoder value
        |> Result.withDefault Dict.empty


groupStringsAndValues : Dict String Token -> ( Dict String String, Dict String Json.Value )
groupStringsAndValues =
    let
        group name token groups =
            case token of
                String_ string ->
                    Tuple.mapFirst (Dict.insert name string) groups

                Value_ value ->
                    Tuple.mapSecond (Dict.insert name value) groups
    in
    Dict.foldl group ( Dict.empty, Dict.empty )


parseString : String -> String -> List Text
parseString _ string =
    let
        step parts =
            Parser.oneOf
                [ Parser.end |> Parser.map (\_ -> Parser.Done (List.reverse parts))
                , Parser.oneOf [ parameter, static ] |> Parser.map (\part -> Parser.Loop (part :: parts))
                ]

        static =
            Parser.chompUntilEndOr "{{"
                |> Parser.getChompedString
                |> Parser.map Static

        parameter =
            Parser.succeed (String.trim >> Parameter)
                |. Parser.symbol "{{"
                |= (Parser.getChompedString <| Parser.chompUntil "}}")
                |. Parser.symbol "}}"
    in
    Parser.run (Parser.loop [] step) string
        |> Result.withDefault []


combineAndRecurse : Path -> Dict Path Module -> ( Module, Dict String Json.Value ) -> Dict Path Module
combineAndRecurse path modules ( strings, values ) =
    Dict.foldl
        (\name -> run (name :: path))
        (Dict.insert path strings modules)
        values
