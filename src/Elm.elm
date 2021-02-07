module Elm exposing (..)

import Dict exposing (Dict)
import Elm.CodeGen exposing (..)
import Elm.Pretty
import List.Extra as List
import String.Case as String
import Text exposing (Text)
import Tuple.Extra as Tuple


type alias File =
    { path : List String
    , content : String
    }


fromText : String -> Dict Text.Path Text.Module -> List File
fromText rootModule =
    let
        preparePath path =
            List.map String.toCamelCaseUpper (rootModule :: path)
    in
    Dict.foldl (\path module_ files -> makeFile (preparePath path) module_ :: files) []


makeFile : Text.Path -> Text.Module -> File
makeFile path module_ =
    { path = path
    , content =
        Dict.toList module_
            |> List.sortBy Tuple.first
            |> List.map (Tuple.apply makeDeclaration)
            |> makeModule path
            |> Elm.Pretty.pretty 120
    }


makeModule : Text.Path -> List Declaration -> Elm.CodeGen.File
makeModule path declarations =
    file (normalModule path []) [] declarations Nothing


makeDeclaration : String -> List Text -> Declaration
makeDeclaration name texts =
    let
        lowerCaseParameter text =
            case text of
                Text.Parameter p ->
                    Text.Parameter (String.toCamelCaseLower p)

                Text.Static s ->
                    Text.Static s
    in
    case texts of
        (Text.Static s) :: [] ->
            valDecl Nothing (Just stringAnn) (String.toCamelCaseLower name) (string s)

        _ ->
            makeFunction (String.toCamelCaseLower name) (List.map lowerCaseParameter texts)


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
