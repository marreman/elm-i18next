port module Main exposing (main)

import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import Json.Decode as Decode exposing (Value)


type alias Options =
    { rootModuleName : String
    , rootDirectory : String
    }


programConfig : Program.Config Options
programConfig =
    Program.config
        |> Program.add
            (OptionsParser.build Options
                |> OptionsParser.with
                    (Option.optionalKeywordArg "rootModuleName"
                        |> Option.map (Maybe.withDefault "Text")
                    )
                |> OptionsParser.with
                    (Option.optionalKeywordArg "rootDirectory"
                        |> Option.map (Maybe.withDefault "./src")
                    )
            )


init : Flags -> Options -> Cmd Never
init { json } options =
    -- let
    --     _ =
    --         Debug.log "options" options
    --     _ =
    --         Debug.log "flags" flags
    -- in
    json
        |> Decode.decodeValue (Decode.dict Decode.string)
        |> Debug.toString
        |> print


type alias Flags =
    Program.FlagsIncludingArgv Input


type alias Input =
    { json : Value }


main : Program.StatelessProgram Never Input
main =
    Program.stateless
        { printAndExitFailure = printAndExitFailure
        , printAndExitSuccess = printAndExitSuccess
        , init = init
        , config = programConfig
        }


port print : String -> Cmd msg


port printAndExitFailure : String -> Cmd msg


port printAndExitSuccess : String -> Cmd msg
