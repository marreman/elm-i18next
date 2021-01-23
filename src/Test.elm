module Test exposing (..)

import Ast
import Json.Encode as E


test =
    Ast.decodeValue json


json : E.Value
json =
    E.object
        [ ( "variable", E.string "foo" )
        , ( "module"
          , E.object
                [ ( "function"
                  , E.string "The time is {{ time }} now."
                  )
                ]
          )
        ]
