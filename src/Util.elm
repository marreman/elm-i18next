module Util exposing (..)


indent : String -> String
indent =
    String.lines >> List.map ((++) (String.repeat 4 " ")) >> String.join "\n"
