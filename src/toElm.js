const { toUpperCamelCase, toLowerCamelCase } = require("./toCamelCase")
const toElm = modules =>
  modules
    .filter(m => m.functions.length)
    .map(m => ({
      path: toModuleName(m.name),
      file: [
        `module ${toModuleName(m.name).join(".")} exposing (..)`,
        m.functions
          .map(f => `${toLowerCamelCase(f.name)} = "${f.body}"`)
          .join("\n\n")
      ].join("\n\n")
    }))

const toModuleName = nameParts => nameParts.map(toUpperCamelCase)

module.exports = toElm
