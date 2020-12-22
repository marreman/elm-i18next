const { toLowerCamelCase, toUpperCamelCase } = require("../src/toCamelCase")

describe("toLowerCamelCase", () => {
  test("simple", () => {
    expect(toLowerCamelCase("foo_bar")).toEqual("fooBar")
  })

  test("complex", () => {
    expect(toLowerCamelCase("foo_bar_baz")).toEqual("fooBarBaz")
  })

  test("with uppercase chars", () => {
    expect(toLowerCamelCase("foo_bAr_baZ")).toEqual("fooBArBaZ")
  })

  test("with dashes", () => {
    expect(toLowerCamelCase("foo-bar-baz")).toEqual("fooBarBaz")
  })

  test("with slashes", () => {
    expect(toLowerCamelCase("foo/bar/baz")).toEqual("fooBarBaz")
  })
})

describe("toUpperCamelCase", () => {
  test("simple", () => {
    expect(toUpperCamelCase("foo_bar")).toEqual("FooBar")
  })

  test("complex", () => {
    expect(toUpperCamelCase("foo_bar_baz")).toEqual("FooBarBaz")
  })

  test("with dots", () => {
    expect(toUpperCamelCase("foo.bar.baz")).toEqual("Foo.Bar.Baz")
  })
})
