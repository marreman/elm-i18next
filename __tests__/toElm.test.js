const toElm = require("../src/toElm")

test("empty array if no functions", () => {
  expect(toElm([{ name: ["foo"], functions: [] }])).toEqual([])
})

test("array with one module", () => {
  expect(
    toElm([
      {
        name: ["foo"],
        functions: [{ name: "bar", body: "baz" }]
      }
    ])
  ).toEqual(['module Foo exposing (..)\n\nbar = "baz"'])
})

test("array multiple modules", () => {
  expect(
    toElm([
      {
        name: ["foo"],
        functions: [{ name: "bar", body: "baz" }]
      },
      {
        name: ["foo2"],
        functions: [{ name: "bar2", body: "baz2" }]
      }
    ])
  ).toEqual([
    'module Foo exposing (..)\n\nbar = "baz"',
    'module Foo2 exposing (..)\n\nbar2 = "baz2"'
  ])
})

test("complex module names", () => {
  expect(
    toElm([
      {
        name: ["foo", "bar", "baz"],
        functions: [{ name: "bar", body: "baz" }]
      }
    ])
  ).toEqual(['module Foo.Bar.Baz exposing (..)\n\nbar = "baz"'])
})
