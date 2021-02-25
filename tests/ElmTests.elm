module ElmTests exposing (..)

import Dict
import Elm
import Elm.DSLParser
import Expect exposing (Expectation)
import Helper exposing (..)
import Test exposing (..)
import Text exposing (Text(..))


tests : Test
tests =
    describe "Elm.fromText"
        [ test "it works with the most simple static case" <|
            \_ ->
                singleTextModule "bar"
                    [ Static "baz"
                    ]
                    |> Elm.fromText "foo"
                    |> expectValidFile simpleStaticFile
        , test "it works with the most simple parameterized case" <|
            \_ ->
                singleTextModule "bar"
                    [ Static "baz"
                    , Parameter "bonk"
                    ]
                    |> Elm.fromText "foo"
                    |> expectValidFile simpleParameterizedFile
        , test "it camel cases everything" <|
            \_ ->
                singleTextModule "foo-19(}_bar-BAZ__@#$%^&"
                    [ Static "im left !@#$%^&*()_+ alone"
                    , Parameter "te-23332st$%^&ing1"
                    ]
                    |> Elm.fromText "a very-^&*%*!STRANGE---ååname"
                    |> expectValidFile camelCasedFile
        , test "it prefixes bad names" <|
            \_ ->
                singleTextModule "456"
                    [ Static "im left alone"
                    , Parameter "789"
                    ]
                    |> Elm.fromText "123"
                    |> expectValidFile prefixedFile
        , test "it returns multiple files" <|
            \_ ->
                Dict.fromList
                    [ ( [], Dict.fromList [ ( "a", [ Static "a" ] ) ] )
                    , ( [ "b" ], Dict.fromList [ ( "b", [ Static "b" ] ) ] )
                    , ( [ "b", "c" ], Dict.fromList [ ( "c", [ Static "c" ] ) ] )
                    , ( [ "b", "c", "d" ], Dict.fromList [ ( "d", [ Static "d" ] ) ] )
                    ]
                    |> Elm.fromText "a"
                    |> Expect.equalLists multipleFiles
        ]



-- EXPECTED FILES


simpleStaticFile : Elm.File
simpleStaticFile =
    { path = [ "Foo" ]
    , content =
        """module Foo exposing (..)


bar : String
bar =
    "baz"
"""
    }


simpleParameterizedFile : Elm.File
simpleParameterizedFile =
    { path = [ "Foo" ]
    , content =
        """module Foo exposing (..)


bar : (String -> a) -> { bonk : a } -> List a
bar fromString parameters =
    [ fromString "baz", parameters.bonk ]
"""
    }


camelCasedFile : Elm.File
camelCasedFile =
    { path = [ "AVeryStrangeName" ]
    , content =
        """module AVeryStrangeName exposing (..)


foo19BarBaz : (String -> a) -> { te23332stIng1 : a } -> List a
foo19BarBaz fromString parameters =
    [ fromString "im left !@#$%^&*()_+ alone", parameters.te23332stIng1 ]
"""
    }


prefixedFile : Elm.File
prefixedFile =
    { path = [ "T123" ]
    , content =
        """module T123 exposing (..)


t456 : (String -> a) -> { p789 : a } -> List a
t456 fromString parameters =
    [ fromString "im left alone", parameters.p789 ]
"""
    }


multipleFiles : List Elm.File
multipleFiles =
    [ { content = "module A.B.C.D exposing (..)\n\n\nd : String\nd =\n    \"d\"\n"
      , path = [ "A", "B", "C", "D" ]
      }
    , { content = "module A.B.C exposing (..)\n\n\nc : String\nc =\n    \"c\"\n"
      , path = [ "A", "B", "C" ]
      }
    , { content = "module A.B exposing (..)\n\n\nb : String\nb =\n    \"b\"\n"
      , path = [ "A", "B" ]
      }
    , { content = "module A exposing (..)\n\n\na : String\na =\n    \"a\"\n"
      , path = [ "A" ]
      }
    ]



-- HELPERS


expectValidFile : Elm.File -> List Elm.File -> Expectation
expectValidFile expectedFile actualFiles =
    case Elm.DSLParser.parse expectedFile.content of
        Ok _ ->
            Expect.equal [ expectedFile ] actualFiles

        Err _ ->
            let
                error =
                    "I couldn't parse this expected Elm file:\n\n"
                        ++ expectedFile.content
                        ++ "\n\nHere's what the code you tested, returned:\n\n"
                        ++ Debug.toString actualFiles
            in
            Expect.fail error
