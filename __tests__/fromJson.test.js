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
      functions: [
        { name: "foo", body: [{ type: "string", value: "bar" }] },
        { name: "bar", body: [{ type: "string", value: "baz" }] }
      ]
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
      functions: [{ name: "bar", body: [{ type: "string", value: "baz" }] }]
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
      functions: [{ name: "bar", body: [{ type: "string", value: "baz" }] }]
    }
  ]

  expect(actual).toEqual(expected)
})

test("parses bodies with curly braces", () => {
  const actual = fromJson(
    {
      foo: "bar {{someVar}}"
    },
    ["ModuleName"]
  )

  const expected = [
    {
      name: ["ModuleName"],
      functions: [
        {
          name: "foo",
          body: [
            { type: "string", value: "bar " },
            { type: "variable", value: "someVar" }
          ]
        }
      ]
    }
  ]

  expect(actual).toEqual(expected)
})

test("parses bodies with curly braces next to each other", () => {
  const actual = fromJson(
    {
      foo: "{{bar}} {{ball}}"
    },
    ["ModuleName"]
  )

  const expected = [
    {
      name: ["ModuleName"],
      functions: [
        {
          name: "foo",
          body: [
            { type: "variable", value: "bar" },
            { type: "string", value: " " },
            { type: "variable", value: "ball" }
          ]
        }
      ]
    }
  ]

  expect(actual).toEqual(expected)
})
