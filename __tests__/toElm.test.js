const toElm = require("../src/toElm")

test("empty array if no functions", () => {
  expect(toElm([{ name: ["foo"], functions: [] }])).toEqual([])
})

test("array with one module", () => {
  expect(
    toElm([
      {
        name: ["foo"],
        functions: [{ name: "bar", body: [{ type: "string", value: "baz" }] }],
      },
    ])
  ).toEqual([
    { path: ["Foo"], file: 'module Foo exposing (..)\n\nbar = "baz"' },
  ])
})

test("multiple functions", () => {
  expect(
    toElm([
      {
        name: ["foo"],
        functions: [
          { name: "bar", body: [{ type: "string", value: "baz" }] },
          { name: "baz", body: [{ type: "string", value: "boy" }] },
        ],
      },
    ])
  ).toEqual([
    {
      path: ["Foo"],
      file: 'module Foo exposing (..)\n\nbar = "baz"\n\nbaz = "boy"',
    },
  ])
})

test("array multiple modules", () => {
  expect(
    toElm([
      {
        name: ["foo"],
        functions: [{ name: "bar", body: [{ type: "string", value: "baz" }] }],
      },
      {
        name: ["foo2"],
        functions: [
          { name: "bar2", body: [{ type: "string", value: "baz2" }] },
        ],
      },
    ])
  ).toEqual([
    { path: ["Foo"], file: 'module Foo exposing (..)\n\nbar = "baz"' },
    { path: ["Foo2"], file: 'module Foo2 exposing (..)\n\nbar2 = "baz2"' },
  ])
})

test("complex module names", () => {
  expect(
    toElm([
      {
        name: ["foo", "bar", "baz"],
        functions: [{ name: "bar", body: [{ type: "string", value: "baz" }] }],
      },
    ])
  ).toEqual([
    {
      path: ["Foo", "Bar", "Baz"],
      file: 'module Foo.Bar.Baz exposing (..)\n\nbar = "baz"',
    },
  ])
})

test("with arguments", () => {
  expect(
    toElm([
      {
        name: ["foo"],
        functions: [
          {
            name: "bar",
            body: [
              { type: "string", value: "baz" },
              { type: "variable", value: "ball" },
            ],
          },
        ],
      },
    ])
  ).toEqual([
    {
      path: ["Foo"],
      file: 'module Foo exposing (..)\n\nbar ball = "baz" ++ ball',
    },
  ])
})

test("with arguments and spaces", () => {
  expect(
    toElm([
      {
        name: ["foo"],
        functions: [
          {
            name: "bar",
            body: [
              { type: "string", value: "  baz  " },
              { type: "variable", value: "ball" },
            ],
          },
        ],
      },
    ])
  ).toEqual([
    {
      path: ["Foo"],
      file: 'module Foo exposing (..)\n\nbar ball = "  baz  " ++ ball',
    },
  ])
})

test("with multiple arguments", () => {
  expect(
    toElm([
      {
        name: ["foo"],
        functions: [
          {
            name: "current_time",
            body: [
              { type: "string", value: "The current date is " },
              { type: "variable", value: "currentDate" },
              { type: "string", value: " and the current time is " },
              { type: "variable", value: "currentTime" },
              { type: "string", value: "." },
            ],
          },
        ],
      },
    ])
  ).toEqual([
    {
      path: ["Foo"],
      file:
        'module Foo exposing (..)\n\ncurrentTime currentDate currentTime = "The current date is " ++ currentDate ++ " and the current time is " ++ currentTime ++ "."',
    },
  ])
})

test("with invalid beginning chars", () => {
  expect(
    toElm([
      {
        name: ["1foo"],
        functions: [{ name: "2bar", body: [{ type: "string", value: "baz" }] }],
      },
    ])
  ).toEqual([
    {
      path: ["Text1foo"],
      file: 'module Text1foo exposing (..)\n\ntext2bar = "baz"',
    },
  ])
})
