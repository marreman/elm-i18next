module Text exposing (..)


greeting : (String -> a) -> { name : a } -> List a
greeting fromString parameters =
    [ fromString "Hello, ", parameters.name, fromString "!" ]


helloWorld : String
helloWorld =
    "Hello World!"
