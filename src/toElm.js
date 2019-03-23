const { toUpperCamelCase, toLowerCamelCase } = require("./toCamelCase")
const toElm = modules =>
  modules
    .filter(m => m.functions.length)
    .map(m => ({
      path: toModuleName(m.name),
      file: [
        `module ${toModuleName(m.name).join(".")} exposing (..)`,
        m.functions.map(toFunction).join("\n\n")
      ].join("\n\n")
    }))

const toModuleName = nameParts => nameParts.map(toUpperCamelCase)
const toFunction = definition => {
  const name = toLowerCamelCase(definition.name)
  const args = definition.body
    .filter(part => part.type === "variable")
    .map(part => part.value)
  const body = definition.body
    .map(part => {
      if (part.type === "string") {
        return `"${part.value}"`
      } else if (part.type === "variable") {
        return part.value
      }
    })
    .join(" ++ ")

  return `${[name].concat(args).join(" ")} = ${body}`
}

module.exports = toElm
