all: build run-tests generate-examples

build:
	elm make src/Program.elm --output=bin/program.js --optimize

run-tests:
	elm-test

generate-examples:
	./examples/helloWorld/generate.sh
	./examples/multiLevel/generate.sh