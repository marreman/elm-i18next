module ElmTests exposing (..)

import Dict
import Elm
import Expect
import Test exposing (Test, test)
import Text


suite : Test
suite =
    test "Text.fromJson" <|
        \_ ->
            Dict.fromList
                [ ( []
                  , Dict.fromList
                        [ ( "foo", [ Text.Static "bar" ] )
                        ]
                  )
                , ( [ "temporality", "date_formats" ]
                  , Dict.fromList
                        [ ( "year difference"
                          , [ Text.Static "The difference between "
                            , Text.Parameter "first_year"
                            , Text.Static " and "
                            , Text.Parameter "second_year"
                            , Text.Static " is "
                            , Text.Parameter "year_difference"
                            , Text.Static "."
                            ]
                          )
                        ]
                  )
                , ( [ "temporality" ]
                  , Dict.fromList
                        [ ( "current_date_and_time"
                          , [ Text.Static "The date is "
                            , Text.Parameter "date"
                            , Text.Static " and the time is "
                            , Text.Parameter "time"
                            ]
                          )
                        , ( "current_time"
                          , [ Text.Static "The time is "
                            , Text.Parameter "time"
                            , Text.Static " now."
                            ]
                          )
                        ]
                  )
                ]
                |> Elm.fromText
                |> Expect.equal
                    []
