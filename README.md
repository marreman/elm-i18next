⚠️ Work in progress ⚠️

# elm-i18next

Generate Elm from i18next JSON files.

## Install

```sh
npm install @marreman/elm-i18next
```

## Use

Given a JSON file `english.json` with the following contents.

```json
{ "hello": "Hello, World!" }
```

Generate Elm from the JSON file using the default options.

```sh
elm-i18next < ./english.json
```

This will create a file `src/Text.elm` with the following contents.

```elm
module Text exposing (..)


hello : String
hello =
    "Hello, World!
```

Please take a look at the more [elaborate example](./example) to learn more.

## Develop

The project has the following dependencies (later versions will most likely work).

- elm: 0.19.1
- elm-test: 0.19.1-revision6
- node: v14.16.0

Either use the included `shell.nix` to get going or install the them on your own.
