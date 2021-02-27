module Text.Greetings exposing (..)


anonymousGreeting : String
anonymousGreeting =
    "Hello, friend!"


userGreeting : (String -> a) -> { name : a } -> List a
userGreeting fromString parameters =
    [ fromString "Hello, ", parameters.name, fromString "!" ]
