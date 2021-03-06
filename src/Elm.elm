module Elm exposing (..)

import Dict
import Elm.CodeGen exposing (..)
import Elm.Pretty
import Html.Attributes exposing (name)
import List.Extra as List
import String.Case as String
import Text exposing (Text)


type alias File =
    { path : List String
    , content : String
    }


fromText : String -> Text.Collection -> List File
fromText rootModule =
    let
        preparePath path =
            List.map (String.toCamelCaseUpper >> adaptName 'T') (rootModule :: path)
    in
    Dict.foldl
        (\path group files ->
            if Dict.isEmpty group then
                files

            else
                makeFile (preparePath path) group :: files
        )
        []


makeFile : Text.Path -> Text.Group -> File
makeFile path module_ =
    { path = path
    , content =
        Dict.toList module_
            |> List.sortBy Tuple.first
            |> List.map (normalize >> makeDeclaration)
            |> makeModule path
            |> Elm.Pretty.pretty 120
    }


makeModule : Text.Path -> List Declaration -> Elm.CodeGen.File
makeModule path declarations =
    file (normalModule path []) [] declarations Nothing


normalize : ( String, List Text ) -> ( String, List Text )
normalize ( name, texts ) =
    let
        normalizeParameter text =
            case text of
                Text.Parameter p ->
                    Text.Parameter (String.toCamelCaseLower (adaptName 'p' p))

                Text.Static s ->
                    Text.Static s
    in
    ( String.toCamelCaseLower (adaptName 't' name), List.map normalizeParameter texts )


{-| Adapts a name so that it becomes a legal Elm name by prefixing with a char if necessary.
-}
adaptName : Char -> String -> String
adaptName prefix name =
    let
        adapt char =
            if Char.isAlpha char then
                String.fromChar char

            else
                String.fromList [ prefix, char ]
    in
    case String.uncons name of
        Just ( char, rest ) ->
            adapt char ++ rest

        Nothing ->
            name


makeDeclaration : ( String, List Text ) -> Declaration
makeDeclaration ( name, texts ) =
    case texts of
        (Text.Static s) :: [] ->
            valDecl Nothing (Just stringAnn) name (string s)

        _ ->
            makeFunction name texts


makeFunction : String -> List Text -> Declaration
makeFunction name texts =
    let
        firstArg =
            funAnn stringAnn (typeVar "a")

        secondArg =
            texts
                |> List.filterMap
                    (\text ->
                        case text of
                            Text.Parameter p ->
                                Just p

                            Text.Static _ ->
                                Nothing
                    )
                |> List.unique
                |> List.map (\p -> ( p, typeVar "a" ))
                |> recordAnn

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
