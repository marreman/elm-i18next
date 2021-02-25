module TextTests exposing (..)

import Dict
import Expect
import Fuzz
import Helper exposing (..)
import Html exposing (text)
import Json.Encode as E
import Test exposing (Test, describe, fuzz, fuzz2, test)
import Text exposing (..)


tests : Test
tests =
    describe "Text.fromJson"
        [ fuzz2 Fuzz.string Helper.textFuzzer "works with any non empty valid string" <|
            \name text ->
                E.object [ ( name, E.string text ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (singleTextModule name
                            [ Static text
                            ]
                        )
        , test "an empty string renders an empty list" <|
            \_ ->
                E.object [ ( "foo", E.string "" ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (singleTextModule "foo" [])
        , fuzz textFuzzer "it constructs one parameter" <|
            \string ->
                E.object [ ( "", E.string ("{{" ++ string ++ "}}") ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (singleTextModule ""
                            [ Parameter string
                            ]
                        )
        , fuzz2 textFuzzer textFuzzer "it constructs many parameters" <|
            \param1 param2 ->
                E.object [ ( "", E.string ("{{" ++ param1 ++ "}}{{" ++ param2 ++ "}}") ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (singleTextModule ""
                            [ Parameter param1
                            , Parameter param2
                            ]
                        )
        , fuzz2 textFuzzer textFuzzer "it preserves static text before, between and around parameters" <|
            \param1 param2 ->
                E.object [ ( "", E.string ("one, {{" ++ param1 ++ "}}, three, {{" ++ param2 ++ "}}, five") ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (singleTextModule ""
                            [ Static "one, "
                            , Parameter param1
                            , Static ", three, "
                            , Parameter param2
                            , Static ", five"
                            ]
                        )
        , test "it flattens deeply nested json properly" <|
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
                            [ ( [], Dict.fromList [ ( "a", [ Static "a" ] ) ] )
                            , ( [ "b" ], Dict.fromList [ ( "b", [ Static "b" ] ) ] )
                            , ( [ "b", "c" ], Dict.fromList [ ( "c", [ Static "c" ] ) ] )
                            , ( [ "b", "c", "d" ], Dict.fromList [ ( "d", [ Static "d" ] ) ] )
                            ]
                        )
        ]
