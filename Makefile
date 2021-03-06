all: build run-tests build-example check-formatting

build:
	elm make ./src/Program.elm --output=./bin/program.js --optimize

run-tests:
	elm-test

build-example:
	rm -r ./example/elm-stuff
	rm -r ./example/src/Text*
	cd ./example; ./build.sh

check-formatting:
	elm-format --validate ./
