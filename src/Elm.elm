module Elm exposing (..)

import Ast exposing (Ast)
import Dict


type alias Module =
    { name : String, values : List String }


fromAst : Ast -> List Module
fromAst ast =
    let
        _ =
            Debug.log "Ast" ast
    in
    toElm "Text" ast []


toElm : String -> Ast -> List Module -> List Module
toElm name ast modules =
    case ast of
        Ast.Group ast_ ->
            -- let
            --         -- module = Module name []
            -- in
            let
                ( v, o ) =
                    Dict.foldl
                        (\name_ ast__ ( values, otherModules ) ->
                            case ast__ of
                                Ast.Group ast___ ->
                                    ( values, ast___ :: otherModules )

                                Ast.Value value ->
                                    ( toElmValue name_ value :: values, otherModules )
                        )
                        ( [], [] )
                        ast_
            in
            Module name v :: modules

        Ast.Value text ->
            []


toElmValue : String -> List Ast.Text -> String
toElmValue name text =
    let
        f =
            List.foldl
                (\t value ->
                    case t of
                        Ast.Static string ->
                            { value | body = ("\"" ++ string ++ "\"") :: value.body }

                        Ast.Parameter parameterName ->
                            { value
                                | body = ("parameters." ++ parameterName) :: value.body
                                , parameters = parameterName :: value.parameters
                            }
                )
                { parameters = []
                , body = []
                }
                text
    in
    name ++ " = " ++ String.join " ++ " f.body
