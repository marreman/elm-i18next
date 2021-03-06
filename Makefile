verify: build run-tests build-example check-formatting

build:
	elm make ./src/Program.elm --output=./bin/program.js --optimize

run-tests:
	elm-test

build-example:
	rm -rf ./example/elm-stuff
	rm -rf ./example/src/Text*
	cd ./example; ./build.sh

check-formatting:
	elm-format --validate ./

generate-changelog:
	node generate-changelog.js > CHANGELOG.md