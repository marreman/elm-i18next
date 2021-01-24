module TextKey exposing (..)

import Dict exposing (Dict)
import Json.Decode as D exposing (Decoder)


decodeValue =
    D.decodeValue decoder
        >> Result.map flatten


type Tree
    = Branch (Dict String Tree)
    | Leaf String



-- type alias Group = Dict String String
-- type alias Groups = Dict String Group


decoder =
    D.oneOf
        [ D.string |> D.map Leaf
        , D.dict (D.lazy (\_ -> decoder)) |> D.map Branch
        ]


flatten : Tree -> List ( String, Dict String String )
flatten tree =
    let
        init =
            { all = []
            , current = ( "Text", Dict.empty )
            }
    in
    []


flatten_ name tree state =
    case tree of
        Leaf string ->
            { state | current = Tuple.mapSecond (Dict.insert name string) state.current }

        Branch dict ->
            { state | all = [] }



-- decodeValue =
--     D.dict D.value
--         |> D.map (Dict.map (\key value -> Debug.log key value))
--         |> D.decodeValue
