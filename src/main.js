const path = require("path")
const fs = require("fs")
const fromJson = require("./fromJson")
const toElm = require("./toElm")

const main = (json, rootModuleName, rootDirectory) => {
  const elmModules = toElm(fromJson(json, [rootModuleName]))

  elmModules.forEach(m => {
    const partialPath = m.path
    const fileName = partialPath.pop()
    const fileDirectory = path.join(rootDirectory, ...partialPath)

    fs.mkdirSync(fileDirectory, { recursive: true })
    fs.writeFileSync(path.join(fileDirectory, `${fileName}.elm`), m.file)
  })
}

module.exports = main
