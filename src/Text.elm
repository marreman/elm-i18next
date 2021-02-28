module Text exposing (..)

import Collection exposing (Collection)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Parser exposing ((|.), (|=), Parser)


type Text
    = Static String
    | Parameter String


type alias Path =
    List String


type Node
    = Leaf String
    | Branch (Dict String Node)


fromJson : Decode.Value -> Result Decode.Error (Collection (List Text))
fromJson json =
    Decode.decodeValue decoder json
        |> Result.map (\nodes -> flatten [] nodes Dict.empty)
        |> Result.map (Collection.mapKeys List.reverse)
        |> Result.map (Collection.mapValues (Parser.run parser >> Result.withDefault []))


decoder : Decoder (Dict String Node)
decoder =
    Decode.dict <|
        Decode.oneOf
            [ Decode.map Leaf Decode.string
            , Decode.map Branch (Decode.lazy (\_ -> decoder))
            ]


parser : Parser (List Text)
parser =
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
    Parser.loop [] step


flatten : Path -> Dict String Node -> Collection String -> Collection String
flatten path nodes initialGroups =
    let
        ( newGroup, moreGroups ) =
            Dict.foldl
                (\name value ( group, groups ) ->
                    case value of
                        Leaf string ->
                            ( Dict.insert name string group
                            , groups
                            )

                        Branch moreNodes ->
                            ( group
                            , flatten (name :: path) moreNodes Dict.empty
                            )
                )
                ( Dict.empty, initialGroups )
                nodes
    in
    Dict.insert path newGroup (Dict.union initialGroups moreGroups)
