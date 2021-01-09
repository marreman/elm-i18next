```elm
type CarNotFoundMessage
    = Text String
    | CarNotFoundMessageChatWithSupport
    | CarNotFoundMessageCallSupport


carNotFoundMessage : List CarNotFoundMessage
carNotFoundMessage =
    [ CarNotFoundMessageChatWithSupport
    , Text " with or "
    , CarNotFoundMessageCallSupport
    , Text " Customer Care."
    ]


test : List (Html msg)
test =
    List.map
        (\a ->
            case a of
                Text t ->
                    Html.text t

                CarNotFoundMessageChatWithSupport ->
                    Html.a [] []

                CarNotFoundMessageCallSupport ->
                    Html.a [] []
        )
        carNotFoundMessage

-- ALT

carNotFoundMessage t a =
    [ a.chatWithSupport, t " with or ", a.callSupport, t " Customer Car." ]


test : Html msg
test =
    div [] <|
        carNotFoundMessage text
            { chatWithSupport = Html.a [] [ text "" ]
            , callSupport = Html.a [] [ text "" ]
            }
```
