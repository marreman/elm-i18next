module Collection exposing (..)

import Dict exposing (Dict)


type alias Collection value =
    Dict (List String) (Dict String value)


mapValues : (value1 -> value2) -> Collection value1 -> Collection value2
mapValues f dict =
    Dict.map
        (\_ subDict ->
            Dict.map (\_ dict__ -> f dict__)
                subDict
        )
        dict


mapKeys : (List String -> List String) -> Collection value -> Collection value
mapKeys f =
    Dict.foldl (\key -> Dict.insert (f key)) Dict.empty
