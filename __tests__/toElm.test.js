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
  ).toEqual([
    { path: ["Foo"], file: 'module Foo exposing (..)\n\nbar = "baz"' }
  ])
})

test("multiple functions", () => {
  expect(
    toElm([
      {
        name: ["foo"],
        functions: [{ name: "bar", body: "baz" }, { name: "baz", body: "boy" }]
      }
    ])
  ).toEqual([
    {
      path: ["Foo"],
      file: 'module Foo exposing (..)\n\nbar = "baz"\n\nbaz = "boy"'
    }
  ])
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
    { path: ["Foo"], file: 'module Foo exposing (..)\n\nbar = "baz"' },
    { path: ["Foo2"], file: 'module Foo2 exposing (..)\n\nbar2 = "baz2"' }
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
  ).toEqual([
    {
      path: ["Foo", "Bar", "Baz"],
      file: 'module Foo.Bar.Baz exposing (..)\n\nbar = "baz"'
    }
  ])
})
