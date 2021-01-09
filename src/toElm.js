const { toUpperCamelCase, toLowerCamelCase } = require("./toCamelCase")

const toElm = (modules) =>
  modules
    .filter((m) => m.functions.length)
    .map((m) => ({
      path: toModuleName(m.name),
      file: [
        `module ${toModuleName(m.name).join(".")} exposing (..)`,
        m.functions
          .map((f) => (f.body.length > 1 ? toFunction(f) : toStatic(f)))
          .join("\n\n"),
      ].join("\n\n"),
    }))

const toValidName = (name) => {
  if (/^[a-zA-Z]/.test(name)) {
    return name
  } else {
    console.info(
      `"${name}" is beginning with an invalid character. It will be prepended with "text".`
    )
    return "text" + name
  }
}

const toModuleName = (nameParts) =>
  nameParts.map(toValidName).map(toUpperCamelCase)

const toStatic = (definition) => {
  const name = toLowerCamelCase(toValidName(definition.name))
  const body = definition.body.map((x) => x.value).join("")
  return `${name} = "${body}"`
}

const toFunction = (definition) => {
  const name = toLowerCamelCase(toValidName(definition.name))
  const body = definition.body
    .map((part) => {
      if (part.type === "string") {
        return `fromString "${part.value}"`
      } else if (part.type === "variable") {
        return `parameters.${toLowerCamelCase(toValidName(part.value))}`
      }
    })
    .join(", ")

  return `${name} fromString parameters = [ ${body} ]`
}

module.exports = toElm
