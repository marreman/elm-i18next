module Main exposing (..)

import Html exposing (Html)
import Text
import Text.Greetings


main : Html msg
main =
    Html.div []
        [ Html.h1 [] [ Html.text Text.helloWorld ]
        , Html.p [] [ Html.text Text.Greetings.anonymousGreeting ]
        , Html.p [] <|
            Text.Greetings.userGreeting Html.text
                { name = Html.text "Martin" }
        , Html.p [] <|
            Text.currentDateAndTime Html.text
                { currentDate = Html.strong [] [ Html.text "27th of Febuary, 2021" ]
                , currentTime = Html.em [] [ Html.text "20:44" ]
                }
        ]
