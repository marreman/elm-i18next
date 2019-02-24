const fromJson = require('./src/fromJson')
const toElm = require('./src/toElm')
const t = require("../translations.json")

const r = toElm(fromJson(t, ["Translations"]))

console.log(r)
