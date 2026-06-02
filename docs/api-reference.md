# API Reference

## `TestSuiteBase`

### `beforeAll()`

Runs once before discovered test entrypoint methods execute.

### `afterAll()`

Runs once after discovered test entrypoint methods finish.

### `beforeEach()`

Runs before each discovered test entrypoint method.

### `afterEach()`

Runs after each discovered test entrypoint method.

### `describe(description)`

Returns a `DescribeScope` for grouping assertion cases inside the current test method.

Parameters:

- `description`: text label for the describe scope

Returns:

- `DescribeScope`

### `failFast`

Suite-level default fail-fast setting. `false` by default.

## `SuiteRunner`

### `SuiteRunner.discoverTestMethods(suite_instance)`

Returns the discovered test entrypoint method names for a suite instance.

Discovery behavior:

- includes non-underscore instance methods
- excludes `beforeAll()`, `afterAll()`, `beforeEach()`, `afterEach()`, `describe()`, and `__New()`

### `SuiteRunner.runSuiteInstance(suite_instance)`

Executes a suite instance and returns a `TestRunOutput` object.

Parameters:

- `suite_instance`: an instantiated suite extending `TestSuiteBase`

Returns:

- `TestRunOutput`

## `DescribeScope`

### `DescribeScope.failFast(enabled := true)`

Sets the default fail-fast behavior for assertion cases created from this describe scope.

Returns:

- the same `DescribeScope` instance for chaining

### `DescribeScope.it(description)`

Creates an `AssertionCase` for one named check.

Returns:

- `AssertionCase`

## `AssertionCase`

### `AssertionCase.failFast(enabled := true)`

Sets fail-fast behavior for this assertion case.

Returns:

- the same `AssertionCase` instance for chaining

### `AssertionCase.expect(actual)`

Creates an `Expectation` for a normal value.

Returns:

- `Expectation`

### `AssertionCase.expectVar(value_factory)`

Creates an `Expectation` for variable-definedness checks.

Parameters:

- `value_factory`: a callable such as `() => x`

Returns:

- `Expectation`

Caveat:

- Use `expectVar(...)` only for definedness semantics. `expect(actual)` cannot preserve `IsSet()`-style variable access behavior.

## `Expectation`

### `toBe(expected)`

Checks direct value equality.

### `toEqual(expected)`

Checks deep structural equality for objects and direct equality for primitive values.

### `toBeTruthy()`

Checks whether the value is truthy.

### `toBeFalsy()`

Checks whether the value is falsy.

### `toBeTrue()`

Checks strict boolean `true`.

### `toBeFalse()`

Checks strict boolean `false`.

### `toBeDefined()`

Checks whether a variable accessor passed through `expectVar(...)` resolves without an `UnsetError`.

### `toBeUndefined()`

Checks whether a variable accessor passed through `expectVar(...)` raises an `UnsetError`.

Caveat:

- Use `expectVar(...)` for undefined checks. Calling `toBeUndefined()` from `expect(...)` records a matcher usage error.

### `toBeEmpty()`

Checks whether the value is the empty string.

### `toBeLessThan(expected)`

Checks `<`.

### `toBeGreaterThan(expected)`

Checks `>`.

### `toHaveLength(expected)`

Checks whether the value exposes `.Length` and whether that length equals `expected`.

### `toStartWith(expected)`

Checks string prefix semantics.

### `toEndWith(expected)`

Checks string suffix semantics.

### `toContain(expected)`

Checks string containment using substring semantics.

### `toMatch(pattern)`

Checks regular expression match behavior.

### `toThrowError(error_class_name := "")`

Checks whether a callable throws, optionally matching the thrown error class.

Parameters:

- `error_class_name`: optional error class name to match

Caveat:

- The expectation value must be callable. Non-callable input is treated as a usage error.

## `CliRenderer`

### `CliRenderer().render(test_run_output)`

Consumes a `TestRunOutput` object and returns CLI-friendly text output.

Parameters:

- `test_run_output`: the output from `SuiteRunner.runSuiteInstance(...)`

Returns:

- string output for terminal or message-box style presentation

### `CliRenderer.joinLines(lines)`

Internal helper that joins lines with newlines. Most users should call `render(...)` instead.

## Output Objects

### `TestRunOutput(schema_version, run_id, created_at)`

Top-level output object for one completed run.

### `SuiteOutput(name)`

Suite-level output object.

### `HookOutput(name, method_name := "", passed := true, error_text := "")`

Lifecycle hook output record.

### `MethodOutput(name)`

Discovered test method output object.

### `DescribeOutput(description, fail_fast := false)`

Describe group output object.

### `AssertionOutput(description, matcher_name, actual_value, expected_value, passed, message := "", fail_fast_source := false, error_text := "")`

Matcher assertion output object.

### `CountOutput()`

Aggregate count object with `passed`, `failed`, and `errored` fields.

### `OutputSerializer.toPortable(test_run_output)`

Converts `TestRunOutput` into a plain-data representation suitable for JSON-style serialization or deferred rendering.

## Renderer Interface

### `IRenderer.render(test_run_output)`

Defines the instance renderer contract. Renderer implementations consume `TestRunOutput` and return renderer-specific output without executing tests.

## Matcher Example

```ahk
d := this.describe("Examples")
d.it("numbers match").expect(5).toBe(5)
d.it("variable is defined").expectVar(() => x).toBeDefined()
d.it("callback throws").expect(callbackBoom).toThrowError()
```
