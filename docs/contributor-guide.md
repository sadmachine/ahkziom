# Contributor Guide

## Execution Flow

`SuiteRunner.runSuiteInstance(...)` is the execution entrypoint.

The current flow is:

1. create a top-level `TestRunOutput`
2. create one `SuiteOutput`
3. run `beforeAll()`
4. discover test methods
5. run `beforeEach()` for each discovered method
6. create `MethodOutput` execution context state
7. execute the test method
8. record `DescribeOutput` and `AssertionOutput` objects
9. run `afterEach()`
10. run `afterAll()`
11. finalize `CountOutput` aggregates

## Output Object Interface

The formal output interface is a canonical object family rooted at `TestRunOutput`.

- `TestRunOutput` represents one completed run.
- `SuiteOutput` represents one executed suite.
- `HookOutput` represents lifecycle hook outcomes.
- `MethodOutput` represents one discovered test method.
- `DescribeOutput` represents one describe group.
- `AssertionOutput` represents one matcher result.
- `CountOutput` stores aggregate pass/fail/error counts.

Use `OutputSerializer.toPortable(...)` to project the canonical objects into plain data for JSON-style export or deferred rendering.

## Result Recording

Result recording is split across focused objects:

- `TestSuiteBase.describe(...)` creates a `DescribeScope`
- `DescribeScope.it(...)` creates an `AssertionCase`
- `AssertionCase.expect(...)` and `AssertionCase.expectVar(...)` create an `Expectation`
- matcher methods append `AssertionOutput` records to the active `DescribeOutput`

## Fail-Fast Resolution

Fail-fast can be controlled at three scopes:

- suite level through `TestSuiteBase.failFast`
- describe scope through `DescribeScope.failFast(...)`
- assertion scope through `AssertionCase.failFast(...)`

The nearest scope wins.

When an assertion fails with fail-fast active, additional assertion recording in the same describe scope stops.

## Matcher Extension

Matcher behavior lives in `src/assertions/Matchers.ahk`.

`src/assertions/Expectation.ahk` exposes matcher entrypoints and records normalized assertion results.

When adding a matcher:

- add the matcher method on `Expectation`
- implement behavior in `Matchers`
- make the matcher return through `Expectation.recordResult(...)`
- document the matcher in `docs/api-reference.md`

## Renderer Interface

`IRenderer` defines the instance renderer contract.

Renderer implementations should expose:

```ahk
render(test_run_output)
```

Renderer responsibilities:

- accept `TestRunOutput`
- transform output data into presentation text or UI
- preserve distinctions between passes, failures, and framework/runtime errors

Renderer non-responsibilities:

- suite discovery
- hook execution
- matcher execution
- test control flow

`CliRenderer` is the first built-in implementation of this interface and is used as `CliRenderer().render(run_output)`.

## Export Strategy

The custom portable representation produced by `OutputSerializer.toPortable(...)` is the default intermediate format target.

Standardized output formats can be added later as exporters if they can accurately represent the library's suite, method, describe, hook, assertion, and error semantics.

## Recommended Extension Practices

- Keep renderers pure consumers of result data.
- Avoid adding execution logic to renderer implementations.
- Keep matcher behavior in `Matchers`, not in suite or renderer code.
- Keep serializers separate from renderers unless the renderer is explicitly an exporter.
