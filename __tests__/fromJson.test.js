const fromJson = require("../src/fromJson")

test("is function", () => {
  expect(typeof fromJson).toBe("function")
})

test("parses flat tree", () => {
  const actual = fromJson(
    {
      foo: "bar",
      bar: "baz"
    },
    ["ModuleName"]
  )

  const expected = [
    {
      name: ["ModuleName"],
      functions: [{ name: "foo", body: "bar" }, { name: "bar", body: "baz" }]
    }
  ]

  expect(actual).toEqual(expected)
})

test("parses nested tree", () => {
  const actual = fromJson(
    {
      foo: { bar: "baz" }
    },
    ["ModuleName"]
  )

  const expected = [
    { name: ["ModuleName"], functions: [] },
    {
      name: ["ModuleName", "foo"],
      functions: [{ name: "bar", body: "baz" }]
    }
  ]

  expect(actual).toEqual(expected)
})

test("parses deeply nested tree", () => {
  const actual = fromJson(
    {
      baz: { foo: { bar: "baz" } }
    },
    ["ModuleName"]
  )

  const expected = [
    { name: ["ModuleName"], functions: [] },
    { name: ["ModuleName", "baz"], functions: [] },
    {
      name: ["ModuleName", "baz", "foo"],
      functions: [{ name: "bar", body: "baz" }]
    }
  ]

  expect(actual).toEqual(expected)
})
