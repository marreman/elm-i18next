port module Program exposing (main)

import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import Elm
import Json.Decode exposing (Value)
import Text


type alias Options =
    { rootElmModule : String
    , outputDirectory : String
    }


programConfig : Program.Config Options
programConfig =
    Program.config
        |> Program.add
            (OptionsParser.build Options
                |> OptionsParser.with
                    (Option.optionalKeywordArg "rootElmModule"
                        |> Option.map (Maybe.withDefault "Text2")
                    )
                |> OptionsParser.with
                    (Option.optionalKeywordArg "outputDirectory"
                        |> Option.map (Maybe.withDefault "./src")
                    )
            )


init : FlagsIncludingArgv -> Options -> Cmd Never
init flags options =
    let
        prependRootDirectory file =
            { file | path = options.outputDirectory :: file.path }
    in
    Text.fromJson flags.json
        |> Elm.fromText options.rootElmModule
        |> List.map (prependRootDirectory >> writeFile)
        |> Cmd.batch


type alias FlagsIncludingArgv =
    Program.FlagsIncludingArgv Flags


type alias Flags =
    { json : Value }


main : Program.StatelessProgram Never Flags
main =
    Program.stateless
        { printAndExitFailure = printAndExitFailure
        , printAndExitSuccess = printAndExitSuccess
        , init = init
        , config = programConfig
        }


port writeFile : Elm.File -> Cmd msg


port print : String -> Cmd msg


port printAndExitFailure : String -> Cmd msg


port printAndExitSuccess : String -> Cmd msg
