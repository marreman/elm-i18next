module Example exposing (..)

import Dict exposing (Dict)
import Expect exposing (Expectation)
import Json.Decode as Decode exposing (Decoder, Value)
import Test exposing (Test, describe, test)



-- the-sett/elm-string-case


expectModule expected actual =
    Expect.equal (Ok <| [ String.join "\n\n" expected ]) actual


suite : Test
suite =
    describe "Parser"
        [ test "one simple field" <|
            \_ ->
                """{ "hello": "world" }"""
                    |> Decode.decodeString decoder
                    |> expectModule
                        [ "module Text exposing (..)"
                        , "hello = \"world\""
                        ]
        , test "two simple fields" <|
            \_ ->
                """{ "hello": "world", "foo": "bar" }"""
                    |> Decode.decodeString decoder
                    |> expectModule
                        [ "module Text exposing (..)"
                        , "foo = \"bar\""
                        , "hello = \"world\""
                        ]
        ]


decoder : Decoder (List String)
decoder =
    Decode.dict Decode.string
        |> Decode.map (toModule "Text")
        |> Decode.map List.singleton



-- |> Decode.map (toModule "Text")


toModule : String -> Dict String String -> String
toModule name values =
    ("module " ++ name ++ " exposing (..)")
        :: List.map toValue (Dict.toList values)
        |> String.join "\n\n"


toValue : ( String, String ) -> String
toValue ( name, body ) =
    String.join "" [ name, " = ", "\"", body, "\"" ]
