const { readFileSync } = require("fs")
const rimraf = require("rimraf")
const path = require("path")
const main = require("../../src/main")
const translations = require("./testTranslations.json")

test("main", () => {
  const root = path.join(__dirname, "TestTranslations")
  const file = name => readFileSync(path.join(root, name), "utf-8")

  // clean up
  rimraf.sync(root)

  // run
  main(translations, "TestTranslations", __dirname)

  expect(file("Account.elm")).toMatchSnapshot()
  expect(file("Signup.elm")).toMatchSnapshot()
  expect(file("Signup/NameStep.elm")).toMatchSnapshot()
})
