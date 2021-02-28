module Text exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Parser exposing ((|.), (|=), Parser)


type Text
    = Static String
    | Parameter String


type alias Group =
    Dict String (List Text)


type alias Path =
    List String


type Node
    = Leaf (List Text)
    | Branch (Dict String Node)


fromJson : Decode.Value -> Result Decode.Error (Dict Path Group)
fromJson json =
    Decode.decodeValue decoder json
        |> Result.map
            (\nodes ->
                flatten [] nodes Dict.empty
                    |> reverseGroupPaths
            )


decoder : Decoder (Dict String Node)
decoder =
    Decode.dict <|
        Decode.oneOf
            [ Decode.map (Parser.run parser >> Result.withDefault [] >> Leaf) Decode.string
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


flatten : Path -> Dict String Node -> Dict Path Group -> Dict Path Group
flatten path nodes initialGroups =
    let
        ( newGroup, moreGroups ) =
            Dict.foldl
                (\name value ( group, groups ) ->
                    case value of
                        Leaf s ->
                            ( Dict.insert name s group
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


reverseGroupPaths : Dict Path Group -> Dict Path Group
reverseGroupPaths =
    Dict.foldl (\path -> Dict.insert (List.reverse path)) Dict.empty
