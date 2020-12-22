const toLowerCamelCase = (s) =>
  s.replace(/([_/-].)/g, ([_, a]) => a.toUpperCase())
const toUpperCamelCase = (s) => {
  return toLowerCamelCase(s)
    .split(".")
    .map(([first, ...rest]) => {
      return first.toUpperCase() + rest.join("")
    })
    .join(".")
}

module.exports = { toLowerCamelCase, toUpperCamelCase }
