# Firstly, generate Elm from the i18next JSON feil.
# Note: hardcoding the default flag values for documentational purposes.
../bin/elm-i18next --rootElmModule=Test --outputDirectory=./src < ./i18next.json

# Then we build.
elm make ./src/Main.elm --output=./elm.js