# Result Format

`SuiteRunner.runSuiteInstance(...)` and `SuiteRunner.runSuiteInstances(...)` return a `TestRunOutput` object.

`TestRunOutput` is the canonical in-memory output interface. Use `OutputSerializer.toPortable(...)` to convert it into a plain-data representation suitable for JSON-style serialization or deferred rendering.

## `TestRunOutput`

- `schemaVersion`: portable output schema version
- `runId`: identifier for the completed run
- `createdAt`: timestamp recorded when the run output is created
- `metadata`: map reserved for future metadata
- `suites`: array of `SuiteOutput` objects
- `counts`: aggregate `CountOutput` for the full run

## `SuiteOutput`

- `name`: suite class name
- `metadata`: map reserved for future metadata
- `hooks`: array of `HookOutput` records
- `methods`: array of `MethodOutput` records
- `counts`: aggregate `CountOutput` for the suite

## `HookOutput`

- `name`: hook name such as `beforeAll`
- `method`: related method name when the hook is per-method
- `passed`: whether the hook completed without throwing
- `error`: error message when a hook fails

## `MethodOutput`

- `name`: discovered test method name
- `describes`: array of `DescribeOutput` records
- `error`: uncaught method-level error message, if any
- `durationMs`: duration field reserved by the MVP result shape

## `DescribeOutput`

- `description`: describe label text
- `failFast`: describe-level fail-fast setting recorded on the scope
- `assertions`: array of `AssertionOutput` records

## `AssertionOutput`

- `description`: `it(...)` description text
- `matcher`: matcher method name such as `toBe`
- `actual`: recorded actual value when available
- `expected`: recorded expected value when relevant
- `passed`: whether the assertion passed
- `message`: failure or informational message
- `failFastSource`: effective fail-fast state used for the assertion
- `error`: framework usage or execution error details when present

## `CountOutput`

- `passed`: number of passing assertions
- `failed`: number of failing assertions
- `errored`: number of errored assertions

## Portable Representation

```ahk
run_output := SuiteRunner.runSuiteInstance(MySuite())
portable := OutputSerializer.toPortable(run_output)
```

The portable representation has the same logical hierarchy but uses plain objects and arrays so it can be projected into JSON or another intermediate format.

## Renderer Relationship

Renderers consume `TestRunOutput`. The built-in CLI renderer is used as an instance:

```ahk
output := CliRenderer().render(run_output)
```

Renderers should treat the output object as read-only presentation data and should not execute tests.
