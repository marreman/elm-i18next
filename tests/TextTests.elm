module TextTests exposing (..)

import Dict
import Expect
import Fuzz
import Helper exposing (..)
import Html exposing (text)
import Json.Encode as E
import Test exposing (..)
import Text exposing (..)


expectOk =
    Expect.equal << Ok


tests : Test
tests =
    describe "Text.fromJson"
        [ fuzz2 Fuzz.string Helper.textFuzzer "works with any non empty valid string" <|
            \name text ->
                E.object [ ( name, E.string text ) ]
                    |> Text.fromJson
                    |> expectOk
                        (singleTextModule name
                            [ Static text
                            ]
                        )
        , test "an empty string renders an empty list" <|
            \_ ->
                E.object [ ( "foo", E.string "" ) ]
                    |> Text.fromJson
                    |> expectOk
                        (singleTextModule "foo" [])
        , fuzz textFuzzer "it constructs one parameter" <|
            \string ->
                E.object [ ( "", E.string ("{{" ++ string ++ "}}") ) ]
                    |> Text.fromJson
                    |> expectOk
                        (singleTextModule ""
                            [ Parameter string
                            ]
                        )
        , fuzz2 textFuzzer textFuzzer "it constructs many parameters" <|
            \param1 param2 ->
                E.object [ ( "", E.string ("{{" ++ param1 ++ "}}{{" ++ param2 ++ "}}") ) ]
                    |> Text.fromJson
                    |> expectOk
                        (singleTextModule ""
                            [ Parameter param1
                            , Parameter param2
                            ]
                        )
        , fuzz2 textFuzzer textFuzzer "it preserves static text before, between and around parameters" <|
            \param1 param2 ->
                E.object [ ( "", E.string ("one, {{" ++ param1 ++ "}}, three, {{" ++ param2 ++ "}}, five") ) ]
                    |> Text.fromJson
                    |> expectOk
                        (singleTextModule ""
                            [ Static "one, "
                            , Parameter param1
                            , Static ", three, "
                            , Parameter param2
                            , Static ", five"
                            ]
                        )
        , test "it works with nested json objects" <|
            \_ ->
                E.object
                    [ ( "a", E.object [ ( "a", E.string "a" ) ] )
                    , ( "b"
                      , E.object
                            [ ( "b", E.string "b" )
                            , ( "b/a", E.object [] )
                            ]
                      )
                    ]
                    |> Text.fromJson
                    |> expectOk
                        (Dict.fromList
                            [ ( [], Dict.fromList [] ) -- keeping empty objects like this one...
                            , ( [ "a" ], Dict.fromList [ ( "a", [ Static "a" ] ) ] )
                            , ( [ "b" ], Dict.fromList [ ( "b", [ Static "b" ] ) ] )
                            , ( [ "b", "b/a" ], Dict.fromList [] ) -- ... and this one
                            ]
                        )
        , test "it works with deeply nested json objects" <|
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
                    |> expectOk
                        (Dict.fromList
                            [ ( [], Dict.fromList [ ( "a", [ Static "a" ] ) ] )
                            , ( [ "b" ], Dict.fromList [ ( "b", [ Static "b" ] ) ] )
                            , ( [ "b", "c" ], Dict.fromList [ ( "c", [ Static "c" ] ) ] )
                            , ( [ "b", "c", "d" ], Dict.fromList [ ( "d", [ Static "d" ] ) ] )
                            ]
                        )
        , test "it fails when given json with int" <|
            \_ ->
                E.object [ ( "a", E.int 1 ) ]
                    |> Text.fromJson
                    |> Expect.err
        , test "it fails when a parameter is not closed" <|
            \_ ->
                E.object [ ( "a", E.string "foo {{ bar" ) ]
                    |> Text.fromJson
                    |> Expect.err
        ]
