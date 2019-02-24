const parse = (o, moduleName) => {
  const moduleKeys = Object.keys(o).filter(k => isObject(o[k]))
  const functionKeys = Object.keys(o).filter(k => !isObject(o[k]))

  const module = [
    {
      name: moduleName,
      functions: functionKeys.map(k => f(k, o[k]))
    }
  ]

  const subModules = moduleKeys.map(name => {
    return parse(o[name], `${moduleName}.${name}`)
  })

  return flatten([module, subModules])
}

const f = (name, body) => ({ name, body })

const isObject = a => !!a && a.constructor === Object

const flatten = arr1 =>
  arr1.reduce(
    (acc, val) =>
      Array.isArray(val) ? acc.concat(flatten(val)) : acc.concat(val),
    []
  )

module.exports = parse
