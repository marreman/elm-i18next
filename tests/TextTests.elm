module TextTests exposing (..)

import Dict exposing (Dict)
import Expect
import Fuzz exposing (Fuzzer)
import Html exposing (text)
import Json.Encode as E
import Test exposing (Test, describe, fuzz, fuzz2, test)
import Text exposing (..)


static : Test
static =
    describe "static text"
        [ fuzz2 Fuzz.string textFuzzer "works with any non empty valid string" <|
            \name text ->
                E.object [ ( name, E.string text ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (single name
                            [ Static text
                            ]
                        )
        , test "an empty string renders an empty list" <|
            \_ ->
                E.object [ ( "foo", E.string "" ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (single "foo" [])
        ]


parameters : Test
parameters =
    describe "parameters"
        [ fuzz textFuzzer "it constructs one parameter" <|
            \string ->
                E.object [ ( "", E.string ("{{" ++ string ++ "}}") ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (single ""
                            [ Parameter string
                            ]
                        )
        , fuzz2 textFuzzer textFuzzer "it constructs many parameters" <|
            \param1 param2 ->
                E.object [ ( "", E.string ("{{" ++ param1 ++ "}}{{" ++ param2 ++ "}}") ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (single ""
                            [ Parameter param1
                            , Parameter param2
                            ]
                        )
        , fuzz2 textFuzzer textFuzzer "it preserves static text before, between and around parameters" <|
            \param1 param2 ->
                E.object [ ( "", E.string ("one, {{" ++ param1 ++ "}}, three, {{" ++ param2 ++ "}}, five") ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (single ""
                            [ Static "one, "
                            , Parameter param1
                            , Static ", three, "
                            , Parameter param2
                            , Static ", five"
                            ]
                        )
        ]


nesting : Test
nesting =
    test "it flattens deeply nested json properly" <|
        \_ ->
            E.object
                [ ( "a", E.string "a" )
                , ( "b"
                  , E.object
                        [ ( "b", E.string "b" )
                        , ( "c"
                          , E.object
                                [ ( "c", E.string "c" )
                                , ( "d"
                                  , E.object
                                        [ ( "d", E.string "d" ) ]
                                  )
                                ]
                          )
                        ]
                  )
                ]
                |> Text.fromJson
                |> Expect.equal
                    (Dict.fromList
                        [ ( [], Dict.fromList [ ( "a", [ Text.Static "a" ] ) ] )
                        , ( [ "b" ], Dict.fromList [ ( "b", [ Text.Static "b" ] ) ] )
                        , ( [ "b", "c" ], Dict.fromList [ ( "c", [ Text.Static "c" ] ) ] )
                        , ( [ "b", "c", "d" ], Dict.fromList [ ( "d", [ Text.Static "d" ] ) ] )
                        ]
                    )



-- HELPERS


single : String -> List Text -> Dict Path Module
single key texts =
    Dict.fromList
        [ ( []
          , Dict.fromList
                [ ( key
                  , texts
                  )
                ]
          )
        ]


textFuzzer : Fuzzer String
textFuzzer =
    Fuzz.char
        |> Fuzz.map
            (\c ->
                if c == ' ' || c == '{' || c == '}' then
                    '-'

                else
                    c
            )
        |> nonEmptyFuzzer
        |> Fuzz.map String.fromList


nonEmptyFuzzer : Fuzzer a -> Fuzzer (List a)
nonEmptyFuzzer fuzzer =
    Fuzz.map2 (::) fuzzer (Fuzz.list fuzzer)
