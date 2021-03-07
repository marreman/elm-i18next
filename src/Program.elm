port module Program exposing (main)

import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import Elm
import Json.Decode as Decode
import Text
import Util exposing (indent)


type alias Options =
    { baseElmModule : String
    , outputDirectory : String
    }


programConfig : Program.Config Options
programConfig =
    Program.config
        |> Program.add
            (OptionsParser.build Options
                |> OptionsParser.with
                    (Option.optionalKeywordArg "base-elm-module"
                        |> Option.map (Maybe.withDefault "Text")
                    )
                |> OptionsParser.with
                    (Option.optionalKeywordArg "output-directory"
                        |> Option.map (Maybe.withDefault "./src")
                    )
            )


init : FlagsIncludingArgv -> Options -> Cmd Never
init flags options =
    let
        prependOutputDirectory file =
            { file | path = options.outputDirectory :: file.path }

        result =
            Text.fromJson flags.json
                |> Result.map (Elm.fromText options.baseElmModule)
    in
    case result of
        Ok files ->
            List.map (prependOutputDirectory >> writeFile) files
                |> Cmd.batch

        Err error ->
            printAndExitFailure <|
                "There was a problem with the JSON file that I got. I can only accept JSON files consisting of objects and strings. Here's the decoding error:\n\n"
                    ++ indent (Decode.errorToString error)


type alias FlagsIncludingArgv =
    Program.FlagsIncludingArgv Flags


type alias Flags =
    { json : Decode.Value }


main : Program.StatelessProgram Never Flags
main =
    Program.stateless
        { printAndExitFailure = printAndExitFailure
        , printAndExitSuccess = printAndExitSuccess
        , init = init
        , config = programConfig
        }


port writeFile : Elm.File -> Cmd msg


port printAndExitFailure : String -> Cmd msg


port printAndExitSuccess : String -> Cmd msg
