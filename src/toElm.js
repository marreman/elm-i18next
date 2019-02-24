const { toUpperCamelCase, toLowerCamelCase } = require("./toCamelCase")
const toElm = modules =>
  modules
    .filter(m => m.functions.length)
    .map(
      m =>
        `module ${toUpperCamelCase(m.name)} exposing (..)\n\n${m.functions.map(
          f => `${toLowerCamelCase(f.name)} = "${f.body}"`
        )}`
    )

module.exports = toElm
