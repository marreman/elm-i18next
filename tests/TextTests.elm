module TextTests exposing (..)

import Dict exposing (Dict)
import Expect
import Fuzz exposing (Fuzzer)
import Json.Encode as E
import Test exposing (Test, describe, fuzz, fuzz2, test)
import Text exposing (..)


static : Test
static =
    describe "static text"
        [ fuzz2 nonEmptyString nonEmptyString "works with any non empty string" <|
            \name text ->
                E.object [ ( name, E.string text ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (single name
                            [ Static text
                            ]
                        )
        ]


parameters : Test
parameters =
    describe "parameters"
        [ fuzz nonEmptyString "it constructs one parameter" <|
            \string ->
                E.object [ ( "", E.string ("{{" ++ string ++ "}}") ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (single ""
                            [ Parameter string
                            ]
                        )
        , test "it constructs many parameters" <|
            \_ ->
                E.object [ ( "", E.string "{{ bar }}{{ baz }}" ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (single ""
                            [ Parameter "bar"
                            , Parameter "baz"
                            ]
                        )
        , test "it preserves static text before, between and around parameters" <|
            \_ ->
                E.object [ ( "", E.string "one, {{ two }}, three, {{ four }}, five" ) ]
                    |> Text.fromJson
                    |> Expect.equal
                        (single ""
                            [ Static "one, "
                            , Parameter "two"
                            , Static ", three, "
                            , Parameter "four"
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


nonEmptyString : Fuzzer String
nonEmptyString =
    Fuzz.map (String.cons 'a') Fuzz.string
        |> Fuzz.map (String.filter (\char -> not <| List.member char [ '{', '}' ]))
        |> Fuzz.map String.trim
