const { toUpperCamelCase, toLowerCamelCase } = require("./toCamelCase")
const toElm = modules =>
  modules
    .filter(m => m.functions.length)
    .map(
      m =>
        `module ${toModuleName(m.name)} exposing (..)\n\n${m.functions.map(
          f => `${toLowerCamelCase(f.name)} = "${f.body}"`
        )}`
    )

const toModuleName = nameParts => nameParts.map(toUpperCamelCase).join(".")

module.exports = toElm
