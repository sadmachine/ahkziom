# AHK Testing Library MVP Design

## Goal

Design an AutoHotkey v2 testing library that combines:

- AutoHotUnit-style suite discovery and lifecycle hooks
- `describe()` and `it()` authoring ergonomics inspired by ahk-unit
- A shared execution core with standardized results that can feed multiple runners, similar in spirit to YUnit's runner model

The first iteration should be an MVP core, with intentional room to expand into a broader "Balanced" release later.

## Project Context

- This repository is a library with minimal existing structure.
- The project must use AutoHotkey v2 syntax and APIs only.
- Public behavior should favor reusable, maintainable library APIs over app-specific shortcuts.
- The testing framework should establish clean execution and result boundaries now so future runners and matchers do not require architectural rewrites.

## Scope

The MVP includes:

- A required base test suite class
- AutoHotUnit-style lifecycle hooks and suite discovery rules
- `describe()`-driven test authoring within discovered suite methods
- A standardized result format independent from rendering
- A basic CLI renderer that consumes the standardized results
- A focused initial matcher set
- Fail-fast controls at suite, describe, and assertion scope

The MVP does not include:

- A GUI runner
- Tags or filtering
- Parameterized tests
- Negation chaining such as `.not()`
- Advanced nesting or graph-based test composition beyond what falls out naturally from the describe model

## Recommended Architecture

### 1. Base Suite Layer

Create a base class that all suites extend. This base class is the public entrypoint for suite authoring and owns:

- suite-level configuration defaults
- the `describe(description)` method
- reserved lifecycle method names

The base class should expose these special methods:

- `beforeAll()`
- `afterAll()`
- `beforeEach()`
- `afterEach()`

These are never treated as tests.

### 2. Suite Execution Layer

Implement a suite runner that:

- instantiates a suite class
- discovers test entrypoint methods
- runs lifecycle hooks in the proper order
- creates a method execution context for each discovered test method
- collects assertion and error data into a normalized result tree

This layer is the authoritative source of execution behavior. All renderers consume its output rather than driving execution themselves.

### 3. Describe / It / Expectation Layer

The `describe(description)` method returns a describe object bound to the current test method execution context.

Within a suite method:

- `describe.it(description)` creates a named assertion case
- `it.expect(actual)` creates an expectation chain
- a matcher finalizes a result entry into the current execution context

This model keeps class-based suite discovery while allowing multiple named checks inside a single discovered suite method.

### 4. Renderer Layer

Renderers only consume the standardized result format.

The MVP ships with:

- a CLI renderer

Future renderers may include:

- a GUI renderer
- other output adapters built on the same normalized result structure

## Public Authoring Model

### Suite Discovery Rules

A suite is a class extending the base suite class.

Discovered test entrypoints are all instance methods that:

- do not start with `_`
- are not one of the reserved lifecycle methods

Ignored methods:

- underscore-prefixed helper methods
- `beforeAll()`
- `afterAll()`
- `beforeEach()`
- `afterEach()`

### Suite Example

```ahk
class MySuite extends TestSuiteBase
{
    beforeAll() {
    }

    beforeEach() {
    }

    myTest() {
        d := this.describe("Math checks")

        x := 2 + 2
        d.it("adds numbers").expect(x).toBe(4)

        y := { a: 1, b: { c: 2 } }
        d.it("compares objects").expect(y).toEqual({ a: 1, b: { c: 2 } })
    }

    _helper() {
    }
}
```

### Public API Shape

- `this.describe(description)`
Returns a describe object tied to the currently executing suite method.

- `describe.it(description)`
Creates a named assertion case.

- `it.expect(actual)`
Starts an expectation chain.

- matchers
Finalize the assertion and append a result record to the current method context.

## Execution Model

For one suite class, execution should proceed as follows:

1. Instantiate the suite.
2. Run `beforeAll()`.
3. For each discovered test method:
4. Run `beforeEach()`.
5. Create a fresh method execution context.
6. Invoke the discovered test method.
7. Finalize all describe and assertion results recorded during that method.
8. Run `afterEach()`.
9. Run `afterAll()`.

The actual implementation can structure this internally however it wants, but public behavior should match that order.

## Failure And Fail-Fast Behavior

### Default Behavior

By default, assertion execution continues after failures so a single discovered suite method can report multiple failures from multiple `it(...)` checks.

### Fail-Fast Scopes

Fail-fast must be configurable at three levels:

- suite-level default
- describe-level default
- assertion-level override

Precedence should be nearest-scope-wins:

1. assertion override
2. describe override
3. suite default

### Naming

Use `failFast` terminology for the public API rather than `exitOnFail`, since it reads consistently at all three levels and matches common testing vocabulary.

## Error Handling

The framework should distinguish between normal test failures and framework/runtime errors.

- assertion mismatches are normal test failures
- unexpected exceptions in hooks, test methods, or matcher execution are errors
- hook failures should be recorded distinctly from assertion failures

If a hook throws, the result model should preserve:

- which hook failed
- the associated suite or method scope
- the exception details needed for renderers to display the failure clearly

If a matcher throws because the assertion is invalid for framework reasons, that should be recorded as a framework usage error rather than a normal matcher failure.

## MVP Matcher Set

The MVP should include these matchers:

- `toBe(expected)`
- `toEqual(expected)`
- `toBeTruthy()`
- `toBeFalsy()`
- `toBeDefined()`
- `toBeEmpty()`
- `toBeLessThan(expected)`
- `toBeGreaterThan(expected)`
- `toContain(expected)`
- `toMatch(pattern)`
- `toThrowError(errorClassName?)`

### Matcher Semantics

- `toBe(expected)` uses direct value comparison semantics appropriate for AHKv2.
- `toEqual(expected)` performs deep structural comparison, including nested objects.
- `toBeTruthy()` checks that the value is truthy.
- `toBeFalsy()` checks that the value is falsy.
- `toBeDefined()` uses `IsSet()` semantics specifically, not empty-string checks.
- `toBeEmpty()` checks that the value is the empty string.
- `toBeLessThan(expected)` checks `<`.
- `toBeGreaterThan(expected)` checks `>`.
- `toContain(expected)` checks string containment behavior.
- `toMatch(pattern)` checks regular expression match behavior.

### `toThrowError(errorClassName?)`

`toThrowError()` expects a callable value passed to `expect(...)`.

Behavior:

- `expect(callback).toThrowError()` passes if invoking the callback throws any error.
- `expect(callback).toThrowError("MyError")` passes only if invoking the callback throws and the thrown error's class name matches `"MyError"`.
- if the value passed to `expect(...)` is not callable, record a framework usage error rather than a normal assertion failure.

## Standardized Result Format

The execution engine should emit a normalized result tree that is renderer-agnostic.

### Suite Result

A suite result should include:

- suite class name
- optional suite description if added later
- configuration snapshot relevant to execution
- hook results
- method results
- aggregate counts for passed, failed, and errored assertions or scopes

### Method Result

A method result should include:

- method name
- one or more describe groups produced during execution
- any uncaught method-level exception
- timing information if collecting it is cheap in the MVP

### Describe Result

A describe result should include:

- description text
- effective fail-fast setting
- ordered assertion case results

### Assertion Case Result

An assertion case result should include:

- the `it(...)` description
- matcher name
- actual summary
- expected summary when relevant
- pass or fail status
- failure message
- fail-fast source scope
- exception details if matcher execution threw

This schema should be treated as the contract between execution and rendering.

## CLI Renderer Requirements

The MVP should ship with a basic CLI renderer that:

- consumes only the standardized result format
- presents suite, method, describe, and assertion outcomes clearly
- follows the desired command-line reporting style inspired by AutoHotUnit
- distinguishes failures from framework errors
- prints enough detail to identify which assertion failed and why

The CLI renderer should not contain execution logic beyond consuming the normalized result data.

## Future Expansion Path

The MVP should deliberately leave room for a future "Balanced" iteration that adds:

- richer assertions
- filtering and selective execution
- at least one additional renderer, likely GUI
- more mature result aggregation and reporting features

The key architectural requirement is that these additions build on the same execution core and result format rather than replacing them.

## Non-Goals For This MVP

- no GUI renderer yet
- no parameterized tests yet
- no tags or filtering yet
- no negation chaining yet
- no separate runner-specific execution paths

## Success Criteria

- Test suites are class-based and must extend a base suite class.
- All non-underscore instance methods, except reserved lifecycle methods, are discovered as test entrypoints.
- `describe()` and `it()` allow multiple named checks inside one discovered test method.
- Execution continues after failures by default.
- Fail-fast can be configured at suite, describe, and assertion scope.
- The MVP matcher set includes `toThrowError(errorClassName?)`.
- `toBeDefined()` uses `IsSet()` semantics.
- `toBeEmpty()` exists as a separate matcher.
- Execution produces a standardized result tree independent from rendering.
- The project ships with a CLI renderer that consumes that result tree.
