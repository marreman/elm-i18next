module Elm exposing (..)

import Dict exposing (Dict)
import Elm.CodeGen exposing (..)
import Elm.Pretty
import List.Extra as List
import String.Case as String
import Text exposing (Text)
import Tuple.Extra as Tuple


type alias File =
    { name : String
    , path : List String
    , content : String
    }


fromText : Dict Text.Path Text.Module -> List File
fromText =
    Dict.foldl (\path mod files -> makeFile path mod :: files) []


makeFile : Text.Path -> Text.Module -> File
makeFile path module_ =
    let
        path_ =
            "Text" :: path |> List.map String.toCamelCaseUpper
    in
    { name = List.last path_ |> Maybe.withDefault "" -- TODO: improve this
    , path = path_
    , content =
        Dict.toList module_
            |> List.sortBy Tuple.first
            |> List.map (Tuple.mapFirst String.toCamelCaseLower >> Tuple.apply makeDeclaration)
            |> makeModule path_
            |> Elm.Pretty.pretty 120
    }


makeModule : Text.Path -> List Declaration -> Elm.CodeGen.File
makeModule path declarations =
    file (normalModule path []) [] declarations Nothing


makeDeclaration : String -> List Text -> Declaration
makeDeclaration name texts =
    case texts of
        (Text.Static s) :: [] ->
            valDecl Nothing (Just stringAnn) name (string s)

        texts_ ->
            makeFunction name texts_


makeFunction : String -> List Text -> Declaration
makeFunction name texts =
    let
        firstArg =
            funAnn stringAnn (typeVar "a")

        secondArg =
            recordAnn <|
                List.filterMap
                    (\text ->
                        case text of
                            Text.Parameter p ->
                                Just ( p, typeVar "a" )

                            Text.Static _ ->
                                Nothing
                    )
                    texts

        returnArg =
            listAnn (typeVar "a")

        body =
            list <|
                List.map
                    (\text ->
                        case text of
                            Text.Static s ->
                                construct "fromString" [ string s ]

                            Text.Parameter p ->
                                val ("parameters." ++ p)
                    )
                    texts
    in
    funDecl
        Nothing
        (Just (funAnn firstArg (funAnn secondArg returnArg)))
        name
        [ varPattern "fromString", varPattern "parameters" ]
        body
