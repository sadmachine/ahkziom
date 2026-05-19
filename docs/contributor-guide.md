# Contributor Guide

## Execution Flow

`SuiteRunner.runSuiteInstance(...)` is the execution entrypoint.

The current MVP flow is:

1. instantiate a suite
2. run `beforeAll()`
3. discover test methods
4. run `beforeEach()` for each discovered method
5. create method execution context state
6. execute the test method
7. record assertion results into the active describe scope
8. run `afterEach()`
9. run `afterAll()`
10. finalize aggregate counts

## Result Recording

Result recording is split across several focused objects:

- `TestSuiteBase.describe(...)` creates a `DescribeScope`
- `DescribeScope.it(...)` creates an `AssertionCase`
- `AssertionCase.expect(...)` and `AssertionCase.expectVar(...)` create an `Expectation`
- matcher methods append normalized assertion records to the active describe result

This separation keeps suite authoring, execution state, and matcher behavior loosely coupled.

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

## Renderer Contract

Renderers consume normalized output data and do not execute tests.

Current renderer responsibilities:

- accept normalized suite output from `SuiteRunner.runSuiteInstance(...)`
- transform output data into presentation text or UI
- preserve distinctions between passes, failures, and framework/runtime errors

Current renderer non-responsibilities:

- suite discovery
- hook execution
- matcher execution
- test control flow

The MVP currently documents this as an architectural contract rather than a formal abstract interface in code.

`CliRenderer` is the first built-in implementation of that renderer contract.

## Future Direction

The architecture is intended to grow toward two explicit interfaces:

- a formal renderer interface
- a formal output object interface

Today, the normalized result object already acts like the output-side contract, and renderers already behave as if they implement a shared rendering contract.

Future work is expected to formalize both sides so execution and presentation can connect through named interfaces instead of an implied object shape.

## Recommended Extension Practices

- Keep renderers pure consumers of result data.
- Avoid adding execution logic to renderer implementations.
- Keep matcher behavior in `Matchers`, not in suite or renderer code.
- Follow implemented MVP behavior closely when expanding examples or docs.

## Current MVP Limitations

- No GUI renderer yet.
- Renderer contract is documented, not formalized in code.
- Output object contract is implied by normalized results, not formalized in code.
- The library is still early-stage and should be documented against actual shipped behavior, not aspirational behavior.
