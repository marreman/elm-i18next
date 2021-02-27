all: build run-tests build-example

build:
	elm make src/Program.elm --output=bin/program.js --optimize

run-tests:
	elm-test

build-example:
	cd ./example; ./build.sh
