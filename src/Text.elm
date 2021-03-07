module Text exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Parser exposing ((|.), (|=), Parser)


type alias Collection =
    Dict Path Group


type alias Path =
    List String


type alias Group =
    Dict String (List Text)


type Text
    = Static String
    | Parameter String


type Node
    = Leaf (List Text)
    | Branch (Dict String Node)


fromJson : Decode.Value -> Result Decode.Error Collection
fromJson json =
    Decode.decodeValue decoder json
        |> Result.map (\nodes -> flatten [] nodes Dict.empty)
        |> Result.map reverseKeys


decoder : Decoder (Dict String Node)
decoder =
    let
        parse string =
            case Parser.run parser string of
                Ok text ->
                    Decode.succeed text

                Err _ ->
                    Decode.fail "Hint: If I've seen '{{' that marks the beginning of a parameter, I also need to it to be closed with '}}'."
    in
    Decode.dict <|
        Decode.oneOf
            [ Decode.string
                |> Decode.andThen parse
                |> Decode.map Leaf
            , Decode.lazy (\_ -> decoder)
                |> Decode.map Branch
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


flatten : Path -> Dict String Node -> Collection -> Collection
flatten path nodes initialCollection =
    let
        ( newGroup, updatedCollection ) =
            Dict.foldl
                (\name value ( group, collection ) ->
                    case value of
                        Leaf string ->
                            ( Dict.insert name string group
                            , collection
                            )

                        Branch moreNodes ->
                            ( group
                            , flatten (name :: path) moreNodes collection
                            )
                )
                ( Dict.empty, initialCollection )
                nodes
    in
    Dict.insert path newGroup updatedCollection


reverseKeys : Collection -> Collection
reverseKeys =
    Dict.foldl (\key -> Dict.insert (List.reverse key)) Dict.empty
