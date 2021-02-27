set -e

# Firstly, generate Elm from the i18next JSON file.
# Note: hardcoding the default flag values for educational purposes.
../bin/elm-i18next --base-elm-module=Text --output-directory=./src < ./i18next.json

# Then we build.
elm make ./src/Main.elm --output=./elm.js