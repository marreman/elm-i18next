module Error exposing (..)

import Json.Decode
import Util exposing (indent)


type Error
    = JsonError Json.Decode.Error


toString : Error -> String
toString error =
    case error of
        JsonError decodingError ->
            "There was a problem with the JSON file that I got. I can only accept JSON files consisting of objects and strings. Here's the decoding error:\n\n"
                ++ indent (Json.Decode.errorToString decodingError)
