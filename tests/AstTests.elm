module AstTests exposing (..)

import Ast exposing (Phrase(..))
import Dict
import Expect
import Json.Encode as E
import Test exposing (Test, test)



-- Reverse module paths
-- Upper camel case module names (the-sett/elm-string-case)
-- Lower camel case values and functions (the-sett/elm-string-case)


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
                                [ ( "foo", Ast.StaticText "bar" )
                                ]
                          )
                        , ( [ "date_formats", "temporality", "Text" ]
                          , Dict.fromList
                                [ ( "year difference"
                                  , Ast.ParameterizedText
                                        [ Ast.StaticPhrase "The difference between "
                                        , Ast.PhraseParameter "first_year"
                                        , Ast.StaticPhrase " and "
                                        , Ast.PhraseParameter "second_year"
                                        , Ast.StaticPhrase " is "
                                        , Ast.PhraseParameter "year_difference"
                                        , Ast.StaticPhrase "."
                                        ]
                                  )
                                ]
                          )
                        , ( [ "temporality", "Text" ]
                          , Dict.fromList
                                [ ( "current_date_and_time"
                                  , Ast.ParameterizedText
                                        [ Ast.StaticPhrase "The date is "
                                        , Ast.PhraseParameter "date"
                                        , Ast.StaticPhrase " and the time is "
                                        , Ast.PhraseParameter "time"
                                        ]
                                  )
                                , ( "current_time"
                                  , Ast.ParameterizedText
                                        [ Ast.StaticPhrase "The time is "
                                        , Ast.PhraseParameter "time"
                                        , Ast.StaticPhrase " now."
                                        ]
                                  )
                                ]
                          )
                        ]
                    )
