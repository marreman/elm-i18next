module Text exposing (..)


currentDateAndTime : (String -> a) -> { currentDate : a, currentTime : a } -> List a
currentDateAndTime fromString parameters =
    [ fromString "The current date is "
    , parameters.currentDate
    , fromString " and the time is "
    , parameters.currentTime
    ]


helloWorld : String
helloWorld =
    "Hello World!"
