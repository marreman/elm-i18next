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


makeModule : String -> Ast -> ( String, String )
makeModule name ast =
    ( name, "" )


makeFunction : String -> List Ast.Part -> String
makeFunction name parts =
    let
        body =
            List.foldl
                (\part bodySoFar ->
                    case part of
                        Ast.Text string ->
                            ("fromString \"" ++ string ++ "\"") :: bodySoFar

                        Ast.Parameter parameterName ->
                            ("parameters." ++ parameterName) :: bodySoFar
                )
                []
                parts
    in
    name ++ " fromString parameters = " ++ String.join " ++ " List.reverse body


makeValue : String -> String -> String
makeValue name body =
    name ++ " = " ++ "\"" ++ body ++ "\""



-- toElm : String -> Ast -> List Module -> List Module
-- toElm name ast modules =
--     case ast of
--         Ast.Group ast_ ->
--             -- let
--             --         -- module = Module name []
--             -- in
--             let
--                 ( v, o ) =
--                     Dict.foldl
--                         (\name_ ast__ ( values, otherModules ) ->
--                             case ast__ of
--                                 Ast.Group ast___ ->
--                                     ( values, ast___ :: otherModules )
--                                 Ast.Value value ->
--                                     ( toElmValue name_ value :: values, otherModules )
--                         )
--                         ( [], [] )
--                         ast_
--             in
--             Module name v :: modules
--         Ast.Value text ->
--             []
