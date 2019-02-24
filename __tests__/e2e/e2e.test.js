const main = require("../../src/main")
const translations = require("./translations.json")

test("main", () => {
  const actual = main(translations, "Translations", __dirname)

})
