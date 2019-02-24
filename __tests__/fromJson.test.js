const parse = require("../src/fromJson")

test("is function", () => {
  expect(typeof parse).toBe("function")
})

test("parses flat tree", () => {
  expect(parse({ foo: "bar", bar: "baz" }, "ModuleName")).toEqual([
    {
      name: "ModuleName",
      functions: [{ name: "foo", body: "bar" }, { name: "bar", body: "baz" }]
    }
  ])
})

test("parses nested tree", () => {
  expect(parse({ foo: { bar: "baz" } }, "ModuleName")).toEqual([
    { name: "ModuleName", functions: [] },
    {
      name: "ModuleName.foo",
      functions: [{ name: "bar", body: "baz" }]
    }
  ])
})

test("parses deeply nested tree", () => {
  expect(
    parse(
      {
        baz: { foo: { bar: "baz" } }
      },
      "ModuleName"
    )
  ).toEqual([
    { name: "ModuleName", functions: [] },
    { name: "ModuleName.baz", functions: [] },
    {
      name: "ModuleName.baz.foo",
      functions: [{ name: "bar", body: "baz" }]
    }
  ])
})
