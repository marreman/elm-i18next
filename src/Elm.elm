module Elm exposing (..)

import Ast exposing (Ast)


type alias Module =
    { name : String, values : List String }



-- fromAst : Ast -> List Module
-- fromAst ast =
--     let
--         _ =
--             Debug.log "Ast" ast
--     in
--     toElm "Text" ast []


makeModule : String -> Ast -> ( String, String )
makeModule name ast =
    ( "", "" )



-- ("module " ++ name ++ " exposing (..)")
--     :: List.map toValue (Dict.toList values)
--     |> String.join "\n\n"


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
    name ++ " fromString parameters = " ++ String.join " ++ " (List.reverse body)


makeValue : String -> String -> String
makeValue name body =
    name ++ " = " ++ "\"" ++ body ++ "\""
