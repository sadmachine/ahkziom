# Runner Reliability And DX Design

## Purpose

Improve test-runner reliability and contributor feedback while preserving exhaustive suite execution. A failed or throwing test method must not prevent later discovered test methods from running.

## Execution Semantics

`SuiteRunner.runSuiteInstance(...)` will continue to discover all runnable test methods on the suite instance and attempt each one. For every discovered method, the runner will:

1. run `beforeEach()` for that method;
2. begin a method execution context;
3. execute the test method;
4. record any thrown method error on the `MethodOutput`;
5. run `afterEach()` for that method;
6. move on to the next discovered method.

Method-level failures and thrown errors are recorded, not used as control-flow signals to stop the suite.

## Fail-Fast Semantics

Fail-fast remains scoped to assertions within a describe scope. It does not stop later test methods from running.

Effective fail-fast continues to resolve with nearest-scope-wins behavior:

- assertion-level `AssertionCase.failFast(...)` overrides describe and suite defaults for that assertion;
- describe-level `DescribeScope.failFast(...)` overrides the suite default for assertions in that describe;
- suite-level `TestSuiteBase.failFast` remains the default when no narrower override is set.

When an assertion fails with effective `failFast = true`, later assertions in the same describe scope are skipped. Other describe scopes and later discovered test methods remain runnable.

## Cleanup Behavior

`afterEach()` should run for every attempted test method, including methods that throw. The suite's internal `__currentExecutionContext` should be cleared after each method and after the suite completes so stale context cannot leak into user code after execution.

## Developer Experience

`tests/helpers/PlanTestRunner.ahk` should run every configured test file even if earlier files fail. It should collect child process exit codes and exit non-zero only after all test files have been attempted.

This gives contributors complete failure information from one run while preserving a useful failing process status for automation.

## Testing

Add or update tests to cover:

- a throwing test method still allows later test methods to run;
- `afterEach()` runs for a throwing test method;
- `__currentExecutionContext` is cleared after suite execution;
- suite-, describe-, and assertion-level fail-fast behavior remains intact;
- the helper runner reports failure only after attempting every configured test file where practical.
