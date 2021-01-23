const json = { simpleKey: "simple value" }
const program = require("./elm").Elm.Main.init({
  flags: { argv: process.argv, versionMessage: "1.2.3", json },
})

program.ports.print.subscribe((message) => {
  console.log(message)
})

program.ports.printAndExitFailure.subscribe((message) => {
  console.log(message)
  process.exit(1)
})

program.ports.printAndExitSuccess.subscribe((message) => {
  console.log(message)
  process.exit(0)
})
