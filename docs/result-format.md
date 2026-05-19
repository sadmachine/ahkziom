# Result Format

`SuiteRunner.runSuiteInstance(...)` returns a normalized suite result object.

This output is the data contract currently consumed by `CliRenderer`, and it represents the shape future renderer implementations are expected to read.

## Suite Result

- `name`: suite class name
- `config`: configuration map for the suite run
- `hooks`: array of hook result records
- `methods`: array of method result records
- `counts`: aggregate pass/fail/error counts

## Hook Result Record

- `name`: hook name such as `beforeAll`
- `method`: related method name when the hook is per-method
- `passed`: whether the hook completed without throwing
- `error`: error message when a hook fails

## Method Result

- `name`: discovered test method name
- `describes`: array of describe result records
- `error`: uncaught method-level error message, if any
- `durationMs`: duration field reserved by the MVP result shape

## Describe Result

- `description`: describe label text
- `failFast`: effective describe-level fail-fast setting recorded on the scope
- `assertions`: array of assertion result records

## Assertion Result

- `description`: `it(...)` description text
- `matcher`: matcher method name such as `toBe`
- `actual`: recorded actual value when available
- `expected`: recorded expected value when relevant
- `passed`: whether the assertion passed
- `message`: failure or informational message
- `failFastSource`: effective fail-fast state used for the assertion
- `error`: framework usage or execution error details when present

## Counts

- `passed`: number of passing assertions
- `failed`: number of failing assertions
- `errored`: number of errored assertions

## Example Output

```ahk
{
    name: "ExampleSuite",
    config: Map(),
    hooks: [
        { name: "beforeAll", method: "", passed: true, error: "" },
        { name: "beforeEach", method: "sampleTest", passed: true, error: "" },
        { name: "afterEach", method: "sampleTest", passed: true, error: "" },
        { name: "afterAll", method: "", passed: true, error: "" }
    ],
    methods: [{
        name: "sampleTest",
        describes: [{
            description: "Math checks",
            failFast: false,
            assertions: [{
                description: "adds numbers",
                matcher: "toBe",
                actual: 5,
                expected: 4,
                passed: false,
                message: "Expected 5 toBe 4",
                failFastSource: false,
                error: ""
            }]
        }],
        error: "",
        durationMs: 0
    }],
    counts: { passed: 0, failed: 1, errored: 0 }
}
```

## Renderer Relationship

The MVP does not yet define a formal output object interface in code, but this normalized structure already behaves as the output-side contract between execution and rendering.

Future versions are expected to formalize that contract so renderers can depend on a dedicated output object interface instead of an implied object shape.
