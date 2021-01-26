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
                    [ { content = module1, name = "name", path = [ "Text", "temporality", "date_formats" ] }
                    , { content = module2, name = "name", path = [ "Text", "temporality" ] }
                    , { content = module3, name = "name", path = [ "Text" ] }
                    ]


module1 : String
module1 =
    """module Text.temporality.date_formats exposing (..)


year difference : (String -> a) -> { first_year : a, second_year : a, year_difference : a } -> List a
year difference fromString parameters =
    [ fromString "The difference between "
    , parameters.first_year
    , fromString " and "
    , parameters.second_year
    , fromString " is "
    , parameters.year_difference
    , fromString "."
    ]
"""


module2 : String
module2 =
    """module Text.temporality exposing (..)


current_time : (String -> a) -> { time : a } -> List a
current_time fromString parameters =
    [ fromString "The time is ", parameters.time, fromString " now." ]


current_date_and_time : (String -> a) -> { date : a, time : a } -> List a
current_date_and_time fromString parameters =
    [ fromString "The date is ", parameters.date, fromString " and the time is ", parameters.time ]
"""


module3 : String
module3 =
    """module Text exposing (..)


foo : String
foo =
    "bar"
"""
