module Test exposing (..)

-- import Elm

import Json.Encode as E
import TextKey


test =
    TextKey.decodeValue json


json : E.Value
json =
    E.object
        [ ( "foo", E.string "bar" )
        , ( "temporality"
          , E.object
                [ ( "current_time"
                  , E.string "The time is {{ time }} now."
                  )
                , ( "current_date_and_time"
                  , E.string "The date is {{ date }} and the time is {{ time }}"
                  )
                ]
          )
        ]
