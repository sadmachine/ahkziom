# Library DX Expansion Design

## Purpose

Improve ahkxiom's user-facing developer experience without changing the current test authoring model. The work adds expected matcher APIs, a reusable multi-suite runner path, a thin script entrypoint, clearer CLI output, better contributor test-runner feedback, and documentation for new and previously under-documented behavior.

## Matcher Expansion

Add these `Expectation` matcher methods and corresponding `Matchers` implementations:

- `toBeTrue()` checks strict boolean `true`.
- `toBeFalse()` checks strict boolean `false`.
- `toBeUndefined()` checks that an `expectVar(...)` accessor raises `UnsetError`.
- `toHaveLength(expected)` checks `.Length` on values that expose it.
- `toStartWith(expected)` checks string prefix semantics.
- `toEndWith(expected)` checks string suffix semantics.

Matcher failures should record clear messages using the existing `AssertionOutput` path. Usage errors, such as calling `toBeUndefined()` without `expectVar(...)` or `toHaveLength(...)` on a value without `.Length`, should record a failed assertion with an `error` value rather than crash the suite.

## Runner API

Add a reusable class-level API for running multiple already-instantiated suites. The expected shape is:

```ahk
run_output := SuiteRunner.runSuiteInstances([FirstSuite(), SecondSuite()])
```

The method should return one `TestRunOutput` containing one `SuiteOutput` per suite instance. Existing `SuiteRunner.runSuiteInstance(...)` behavior remains available for single-suite usage. Multi-suite execution should preserve exhaustive behavior: all suite instances should be attempted, and a failing or throwing method in one suite must not prevent later methods or later suites from running.

## Script Entrypoint

Add a thin script entrypoint, expected at `bin/ahkxiom.ahk`, for terminal use:

```powershell
AutoHotkey64.exe bin\ahkxiom.ahk path\to\suite-file.ahk
```

The suite file remains responsible for choosing how to run and render results by exposing a known callable:

```ahk
AhkxiomMain() {
    run_output := SuiteRunner.runSuiteInstances([MySuite()])
    return CliRenderer().render(run_output)
}
```

The entrypoint loads the provided suite file, verifies `AhkxiomMain` exists, calls it, and writes returned text to stdout when the returned value is not empty. This preserves renderer ownership in the suite file: a future GUI renderer may display its own UI and return an empty string without the entrypoint forcing CLI rendering.

Entrypoint usage errors should write a concise message to stdout/stderr and exit non-zero. Successful execution should exit zero unless the suite-owned `AhkxiomMain()` throws.

## CLI Renderer Improvements

Improve `CliRenderer` output while preserving the current general structure. It should show:

- failed hook names, associated method names when present, and hook error text;
- method-level errors recorded on `MethodOutput.error`;
- assertion `error` text in addition to assertion failure messages;
- the existing summary counts.

The renderer remains a pure consumer of `TestRunOutput`; it must not execute suites, discover tests, or alter result objects.

## Contributor Test Helper DX

Improve `tests/helpers/PlanTestRunner.ahk` so contributors can see progress and failures from one run. The helper should:

- print each test file before running it;
- attempt every configured test file even when earlier files fail;
- collect failed test file paths;
- print a final failed-file summary when any file fails;
- exit non-zero after all files have been attempted if any failed.

## Documentation

Update documentation for all new behavior and any existing behavior touched or newly exposed by this work.

Required documentation updates:

- README: add quick mention of the script entrypoint and a future-work section listing JSON exporter support.
- Getting Started: document running suites through the entrypoint and keeping renderer choice inside `AhkxiomMain()`.
- API Reference: document new matchers, `SuiteRunner.runSuiteInstances(...)`, and `AhkxiomMain()` entrypoint expectations.
- Contributor Guide: document improved test-helper behavior and existing renderer responsibilities if not already clear.
- Result Format: document existing hook errors, method errors, assertion errors, and counts if missing or incomplete.

## Testing

Add or update tests to cover:

- all new matcher pass/fail behavior and usage-error recording;
- multi-suite `SuiteRunner.runSuiteInstances(...)` output shape and exhaustive behavior;
- script entrypoint success and missing-argument/missing-`AhkxiomMain` errors where practical;
- CLI rendering for hook failures, method errors, and assertion error text;
- helper runner progress/failure summary behavior where practical;
- documentation examples remaining syntactically aligned with AutoHotkey v2 style.
