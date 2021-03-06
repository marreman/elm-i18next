all: build run-tests check-formatting build-example 

build:
	elm make ./src/Program.elm --output=./bin/program.js --optimize

run-tests:
	elm-test

check-formatting:
	elm-format --validate ./

build-example:
	rm -r ./example/elm-stuff
	rm -r ./example/src/Text*
	cd ./example; ./build.sh
