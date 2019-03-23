const fromJson = (o, moduleName) => {
  const moduleKeys = Object.keys(o).filter(k => isObject(o[k]))
  const functionKeys = Object.keys(o).filter(k => !isObject(o[k]))

  const module = [
    {
      name: moduleName,
      functions: functionKeys.map(k => createFunction(k, o[k]))
    }
  ]

  const subModules = moduleKeys.map(name => {
    return fromJson(o[name], [...moduleName, name])
  })

  return flatten([module, subModules])
}

const createFunction = (key, value) => {
  const parts = value
    .split(/({{[^{]*}})/)
    .filter(Boolean)
    .map(part => {
      if (/{{[^{]*}}/.test(part)) {
        return {
          type: "variable",
          value: part.replace(/{{(.*)}}/, (_, v) => v)
        }
      } else {
        return { type: "string", value: part }
      }
    })

  return { name: key, body: parts }
}

const isObject = a => !!a && a.constructor === Object

const flatten = arr1 =>
  arr1.reduce(
    (acc, val) =>
      Array.isArray(val) ? acc.concat(flatten(val)) : acc.concat(val),
    []
  )

module.exports = fromJson
