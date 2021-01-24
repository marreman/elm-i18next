module AstTests exposing (..)

import Ast
import Dict exposing (Dict)
import Expect exposing (Expectation)
import Json.Encode as E
import Test exposing (Test, describe, test)



-- the-sett/elm-string-case


suite : Test
suite =
    test "Ast.fromJson" <|
        \_ ->
            E.object
                [ ( "foo", E.string "bar" )
                , ( "temporality"
                  , E.object
                        [ ( "current_time", E.string "The time is {{ time }} now." )
                        , ( "current_date_and_time", E.string "The date is {{ date }} and the time is {{ time }}" )
                        , ( "date_formats"
                          , E.object
                                [ ( "year difference", E.string "The difference between {{ first_year }} and {{ second_year }} is {{ year_difference }}." )
                                ]
                          )
                        ]
                  )
                ]
                |> Ast.fromJson
                |> Expect.equal
                    (Dict.fromList
                        [ ( [ "Text" ]
                          , Dict.fromList
                                [ ( "foo", "bar" )
                                ]
                          )
                        , ( [ "date_formats", "temporality", "Text" ]
                          , Dict.fromList
                                [ ( "year difference", "The difference between {{ first_year }} and {{ second_year }} is {{ year_difference }}." )
                                ]
                          )
                        , ( [ "temporality", "Text" ]
                          , Dict.fromList
                                [ ( "current_date_and_time", "The date is {{ date }} and the time is {{ time }}" )
                                , ( "current_time", "The time is {{ time }} now." )
                                ]
                          )
                        ]
                    )
