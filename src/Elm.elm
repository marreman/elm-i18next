module Elm exposing (..)

import Dict exposing (Dict)
import Elm.Function.Body
import Json.Decode as D exposing (Decoder)
import Json.Encode as E


type Elm
    = Module (Dict String Elm)
    | Function Elm.Function.Body.Body
    | Variable String


decoder : Decoder Elm
decoder =
    D.oneOf
        [ D.map Module (D.dict (D.lazy (\_ -> decoder)))
        , D.map Function (D.string |> D.andThen parseParameters)
        , D.map Variable D.string
        ]


parseParameters : String -> Decoder Elm.Function.Body.Body
parseParameters string =
    case Elm.Function.Body.parse string of
        Ok parameters ->
            D.succeed parameters

        Err _ ->
            D.fail "failed to parse parameters"


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
