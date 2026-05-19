# AHK Testing Library MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the MVP core of an AutoHotkey v2 testing library with class-based suite discovery, `describe()`-driven assertions, a normalized result model, and a CLI renderer.

**Architecture:** The implementation should center on a single execution engine that discovers suite methods, runs lifecycle hooks, records normalized results, and stays independent from output concerns. Assertions and matchers should append structured results into a method execution context, while the CLI renderer consumes only the normalized result tree.

**Tech Stack:** AutoHotkey v2, Markdown documentation, library source files under `src/`, tests under `tests/`

---

## Planned File Structure

- Create: `src/Ahkxiom.ahk`
Main public include file that wires together the MVP library entrypoints.

- Create: `src/core/TestSuiteBase.ahk`
Base class for suite authoring, suite-level config, and `describe()` creation.

- Create: `src/core/SuiteRunner.ahk`
Suite discovery, lifecycle hook execution, method execution, and result aggregation.

- Create: `src/core/ExecutionContext.ahk`
State container for one suite run and one method run, including fail-fast resolution.

- Create: `src/core/Results.ahk`
Normalized result object builders and aggregate counting helpers.

- Create: `src/assertions/DescribeScope.ahk`
Implements `describe()` scope and `it()` creation.

- Create: `src/assertions/AssertionCase.ahk`
Owns one `it(...)` chain and starts `expect(...)`.

- Create: `src/assertions/Expectation.ahk`
Expectation chain entrypoint, matcher dispatch, and assertion-level fail-fast override.

- Create: `src/assertions/Matchers.ahk`
Matcher implementations including deep equality, string checks, and throw checks.

- Create: `src/renderers/CliRenderer.ahk`
Consumes normalized results and prints command-line output.

- Create: `tests/TestBootstrap.ahk`
Common test include file for loading the library and shared test helpers.

- Create: `tests/helpers/PlanTestRunner.ahk`
Minimal script to execute focused tests during development.

- Create: `tests/unit/TestSuiteBaseTests.ahk`
Tests for suite discovery rules, reserved methods, and describe creation.

- Create: `tests/unit/DescribeAndExpectationTests.ahk`
Tests for `describe()`, `it()`, matcher chaining, and fail-fast precedence.

- Create: `tests/unit/MatcherTests.ahk`
Focused matcher behavior tests including `toThrowError()` and `toBeDefined()`.

- Create: `tests/unit/SuiteRunnerTests.ahk`
Tests for lifecycle ordering, continue-on-failure behavior, and error recording.

- Create: `tests/unit/CliRendererTests.ahk`
Tests for rendering normalized results into CLI output.

- Create: `tests/functional/MvpFlowTests.ahk`
Functional tests for end-to-end suite execution and result rendering.

- Modify: `README.md`
Document MVP usage once the library exists.

### Task 1: Scaffold The Library Entry Point And Test Harness

**Files:**
- Create: `src/Ahkxiom.ahk`
- Create: `tests/TestBootstrap.ahk`
- Create: `tests/helpers/PlanTestRunner.ahk`

- [ ] **Step 1: Create the public library include file**

```ahk
#Requires AutoHotkey v2.0

#Include core/TestSuiteBase.ahk
#Include core/SuiteRunner.ahk
#Include core/ExecutionContext.ahk
#Include core/Results.ahk
#Include assertions/DescribeScope.ahk
#Include assertions/AssertionCase.ahk
#Include assertions/Expectation.ahk
#Include assertions/Matchers.ahk
#Include renderers/CliRenderer.ahk
```

- [ ] **Step 2: Create the shared test bootstrap file**

```ahk
#Requires AutoHotkey v2.0

#Include ..\src\Ahkxiom.ahk
```

- [ ] **Step 3: Create a minimal development test runner script**

```ahk
#Requires AutoHotkey v2.0

#Include ..\TestBootstrap.ahk

test_files := [
    A_ScriptDir "\\..\\unit\\TestSuiteBaseTests.ahk",
    A_ScriptDir "\\..\\unit\\DescribeAndExpectationTests.ahk",
    A_ScriptDir "\\..\\unit\\MatcherTests.ahk",
    A_ScriptDir "\\..\\unit\\SuiteRunnerTests.ahk",
    A_ScriptDir "\\..\\unit\\CliRendererTests.ahk",
    A_ScriptDir "\\..\\functional\\MvpFlowTests.ahk"
]

for test_file in test_files {
    if (FileExist(test_file)) {
        RunWait('"' A_AhkPath '" /ErrorStdOut "' test_file '"')
    }
}
```

- [ ] **Step 4: Verify the harness loads with no syntax errors**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\helpers\PlanTestRunner.ahk"`
Expected: the script exits without syntax errors; some test files may still be missing at this stage.

- [ ] **Step 5: Commit the scaffold**

```bash
git add src/Ahkxiom.ahk tests/TestBootstrap.ahk tests/helpers/PlanTestRunner.ahk
git commit -m "chore: scaffold ahk testing library layout"
```

### Task 2: Define Result Builders And Execution Context State

**Files:**
- Create: `src/core/Results.ahk`
- Create: `src/core/ExecutionContext.ahk`
- Create: `tests/unit/SuiteRunnerTests.ahk`

- [ ] **Step 1: Write the failing tests for normalized result creation**

```ahk
#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

result := Results.newSuiteResult("ExampleSuite")
if (result.name != "ExampleSuite") {
    throw Error("Expected suite result name to be ExampleSuite")
}

method_result := Results.newMethodResult("exampleTest")
if (method_result.name != "exampleTest") {
    throw Error("Expected method result name to be exampleTest")
}

describe_result := Results.newDescribeResult("Numbers", false)
if (describe_result.description != "Numbers") {
    throw Error("Expected describe result description to be Numbers")
}
```

- [ ] **Step 2: Run the focused test to verify it fails**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\SuiteRunnerTests.ahk"`
Expected: FAIL with missing `Results` members.

- [ ] **Step 3: Implement the normalized result builders**

```ahk
class Results
{
    static newSuiteResult(name) {
        return {
            name: name,
            config: Map(),
            hooks: [],
            methods: [],
            counts: { passed: 0, failed: 0, errored: 0 }
        }
    }

    static newMethodResult(name) {
        return {
            name: name,
            describes: [],
            error: "",
            durationMs: 0
        }
    }

    static newDescribeResult(description, fail_fast) {
        return {
            description: description,
            failFast: fail_fast,
            assertions: []
        }
    }
}
```

- [ ] **Step 4: Implement the execution context state container**

```ahk
class ExecutionContext
{
    __New(suite_instance, suite_result, suite_fail_fast := false) {
        this.suite := suite_instance
        this.suiteResult := suite_result
        this.suiteFailFast := suite_fail_fast
        this.currentMethod := ""
        this.currentMethodResult := ""
    }

    beginMethod(method_name) {
        this.currentMethod := method_name
        this.currentMethodResult := Results.newMethodResult(method_name)
        return this.currentMethodResult
    }

    resolveFailFast(describe_override := unset, assertion_override := unset) {
        if (IsSet(assertion_override)) {
            return assertion_override
        }

        if (IsSet(describe_override)) {
            return describe_override
        }

        return this.suiteFailFast
    }
}
```

- [ ] **Step 5: Re-run the focused test**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\SuiteRunnerTests.ahk"`
Expected: PASS for result and context creation checks.

- [ ] **Step 6: Commit the result model and context**

```bash
git add src/core/Results.ahk src/core/ExecutionContext.ahk tests/unit/SuiteRunnerTests.ahk
git commit -m "feat: add result builders and execution context"
```

### Task 3: Implement The Base Suite API And Discovery Rules

**Files:**
- Create: `src/core/TestSuiteBase.ahk`
- Create: `tests/unit/TestSuiteBaseTests.ahk`

- [ ] **Step 1: Write the failing tests for `describe()` and discovery rules**

```ahk
#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

class SampleSuite extends TestSuiteBase
{
    beforeAll() {
    }

    visibleTest() {
    }

    _helper() {
    }
}

suite := SampleSuite()
describe_scope := suite.describe("Example")
if (describe_scope.description != "Example") {
    throw Error("Expected describe() to return a describe scope")
}

methods := SuiteRunner.discoverTestMethods(suite)
if (methods.Length != 1 || methods[1] != "visibleTest") {
    throw Error("Expected only visibleTest to be discovered")
}
```

- [ ] **Step 2: Run the base suite test and verify it fails**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\TestSuiteBaseTests.ahk"`
Expected: FAIL with missing `TestSuiteBase` and discovery behavior.

- [ ] **Step 3: Implement the base suite class**

```ahk
class TestSuiteBase
{
    __New() {
        this.failFast := false
        this.__currentExecutionContext := ""
    }

    beforeAll() {
    }

    afterAll() {
    }

    beforeEach() {
    }

    afterEach() {
    }

    describe(description) {
        return DescribeScope(this.__currentExecutionContext, description)
    }
}
```

- [ ] **Step 4: Implement method discovery on the runner**

```ahk
class SuiteRunner
{
    static reservedMethodNames := Map(
        "beforeAll", true,
        "afterAll", true,
        "beforeEach", true,
        "afterEach", true
    )

    static discoverTestMethods(suite_instance) {
        methods := []

        for method_name, method_value in suite_instance.OwnProps() {
            if (SubStr(method_name, 1, 1) = "_") {
                continue
            }

            if (SuiteRunner.reservedMethodNames.Has(method_name)) {
                continue
            }

            if (HasMethod(suite_instance, method_name)) {
                methods.Push(method_name)
            }
        }

        return methods
    }
}
```

- [ ] **Step 5: Re-run the base suite test**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\TestSuiteBaseTests.ahk"`
Expected: PASS for `describe()` creation and discovery filtering.

- [ ] **Step 6: Commit the suite base and discovery logic**

```bash
git add src/core/TestSuiteBase.ahk src/core/SuiteRunner.ahk tests/unit/TestSuiteBaseTests.ahk
git commit -m "feat: add base suite and method discovery"
```

### Task 4: Build `describe()`, `it()`, And Expectation Chaining

**Files:**
- Create: `src/assertions/DescribeScope.ahk`
- Create: `src/assertions/AssertionCase.ahk`
- Create: `src/assertions/Expectation.ahk`
- Create: `tests/unit/DescribeAndExpectationTests.ahk`

- [ ] **Step 1: Write the failing tests for `it()` and `expect()` chaining**

```ahk
#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

suite_result := Results.newSuiteResult("ExampleSuite")
context := ExecutionContext("", suite_result)
context.beginMethod("exampleTest")

d := DescribeScope(context, "Numbers")
assertion_case := d.it("adds numbers")
expectation := assertion_case.expect(4)

if (assertion_case.description != "adds numbers") {
    throw Error("Expected it() to capture the assertion description")
}

if (expectation.actual != 4) {
    throw Error("Expected expect() to capture the actual value")
}
```

- [ ] **Step 2: Run the chaining test and verify it fails**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\DescribeAndExpectationTests.ahk"`
Expected: FAIL with missing describe and expectation types.

- [ ] **Step 3: Implement the describe scope and assertion case types**

```ahk
class DescribeScope
{
    __New(execution_context, description) {
        this.executionContext := execution_context
        this.description := description
        this.failFastOverride := unset
        this.result := Results.newDescribeResult(description, false)
        execution_context.currentMethodResult.describes.Push(this.result)
    }

    failFast(enabled := true) {
        this.failFastOverride := enabled
        this.result.failFast := enabled
        return this
    }

    it(description) {
        return AssertionCase(this, description)
    }
}

class AssertionCase
{
    __New(describe_scope, description) {
        this.describeScope := describe_scope
        this.description := description
        this.failFastOverride := unset
    }

    failFast(enabled := true) {
        this.failFastOverride := enabled
        return this
    }

    expect(actual) {
        return Expectation(this, actual)
    }
}
```

- [ ] **Step 4: Implement the expectation entrypoint and result recording helper**

```ahk
class Expectation
{
    __New(assertion_case, actual) {
        this.assertionCase := assertion_case
        this.actual := actual
    }

    recordResult(matcher_name, passed, expected := "", message := "", error_text := "") {
        describe_scope := this.assertionCase.describeScope
        fail_fast := describe_scope.executionContext.resolveFailFast(
            describe_scope.failFastOverride,
            this.assertionCase.failFastOverride
        )

        describe_scope.result.assertions.Push({
            description: this.assertionCase.description,
            matcher: matcher_name,
            actual: this.actual,
            expected: expected,
            passed: passed,
            message: message,
            failFastSource: fail_fast,
            error: error_text
        })

        return passed
    }
}
```

- [ ] **Step 5: Re-run the chaining test**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\DescribeAndExpectationTests.ahk"`
Expected: PASS for describe, it, and expect object creation.

- [ ] **Step 6: Commit the authoring chain**

```bash
git add src/assertions/DescribeScope.ahk src/assertions/AssertionCase.ahk src/assertions/Expectation.ahk tests/unit/DescribeAndExpectationTests.ahk
git commit -m "feat: add describe and expectation chain"
```

### Task 5: Implement The MVP Matchers

**Files:**
- Create: `src/assertions/Matchers.ahk`
- Create: `tests/unit/MatcherTests.ahk`
- Modify: `src/assertions/Expectation.ahk`

- [ ] **Step 1: Write the failing matcher tests**

```ahk
#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

suite_result := Results.newSuiteResult("ExampleSuite")
context := ExecutionContext("", suite_result)
context.beginMethod("matcherTest")

d := DescribeScope(context, "Matchers")
d.it("toBe passes").expect(100).toBe(100)
d.it("toBeEmpty passes").expect("").toBeEmpty()
d.it("toContain passes").expect("Hello World").toContain("World")
d.it("toThrowError passes").expect(() => (throw Error("bad"))).toThrowError()

assertions := d.result.assertions
if (assertions.Length != 4) {
    throw Error("Expected four matcher assertions")
}

for assertion in assertions {
    if (!assertion.passed) {
        throw Error("Expected matcher assertion to pass")
    }
}
```

- [ ] **Step 2: Run the matcher tests and verify they fail**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\MatcherTests.ahk"`
Expected: FAIL because matcher methods are missing.

- [ ] **Step 3: Implement matcher dispatch methods on `Expectation`**

```ahk
class Expectation
{
    toBe(expected) {
        return Matchers.toBe(this, expected)
    }

    toEqual(expected) {
        return Matchers.toEqual(this, expected)
    }

    toBeTruthy() {
        return Matchers.toBeTruthy(this)
    }

    toBeFalsy() {
        return Matchers.toBeFalsy(this)
    }

    toBeDefined() {
        return Matchers.toBeDefined(this)
    }

    toBeEmpty() {
        return Matchers.toBeEmpty(this)
    }

    toBeLessThan(expected) {
        return Matchers.toBeLessThan(this, expected)
    }

    toBeGreaterThan(expected) {
        return Matchers.toBeGreaterThan(this, expected)
    }

    toContain(expected) {
        return Matchers.toContain(this, expected)
    }

    toMatch(pattern) {
        return Matchers.toMatch(this, pattern)
    }

    toThrowError(error_class_name := "") {
        return Matchers.toThrowError(this, error_class_name)
    }
}
```

- [ ] **Step 4: Implement the matcher helpers**

```ahk
class Matchers
{
    static toBe(expectation, expected) {
        return expectation.recordResult("toBe", expectation.actual = expected, expected)
    }

    static toBeEmpty(expectation) {
        return expectation.recordResult("toBeEmpty", expectation.actual = "", "")
    }

    static toContain(expectation, expected) {
        passed := InStr(expectation.actual, expected) > 0
        return expectation.recordResult("toContain", passed, expected)
    }

    static toThrowError(expectation, error_class_name := "") {
        callback := expectation.actual

        if (!HasMethod(callback, "Call")) {
            expectation.recordResult("toThrowError", false, error_class_name, "Expected a callable value", "NotCallable")
            return false
        }

        try {
            callback.Call()
            return expectation.recordResult("toThrowError", false, error_class_name, "Expected callback to throw")
        } catch as err {
            if (error_class_name = "") {
                return expectation.recordResult("toThrowError", true, error_class_name)
            }

            return expectation.recordResult("toThrowError", err.__Class = error_class_name, error_class_name)
        }
    }
}
```

- [ ] **Step 5: Expand the matcher file to cover the remaining MVP matchers**

```ahk
class Matchers
{
    static toEqual(expectation, expected) {
        passed := Matchers.deepEqual(expectation.actual, expected)
        return expectation.recordResult("toEqual", passed, expected)
    }

    static toBeTruthy(expectation) {
        return expectation.recordResult("toBeTruthy", !!expectation.actual)
    }

    static toBeFalsy(expectation) {
        return expectation.recordResult("toBeFalsy", !expectation.actual)
    }

    static toBeDefined(expectation) {
        return expectation.recordResult("toBeDefined", IsSet(expectation.actual))
    }

    static toBeLessThan(expectation, expected) {
        return expectation.recordResult("toBeLessThan", expectation.actual < expected, expected)
    }

    static toBeGreaterThan(expectation, expected) {
        return expectation.recordResult("toBeGreaterThan", expectation.actual > expected, expected)
    }

    static toMatch(expectation, pattern) {
        return expectation.recordResult("toMatch", RegExMatch(expectation.actual, pattern) > 0, pattern)
    }

    static deepEqual(left, right) {
        if (Type(left) != Type(right)) {
            return false
        }

        if (!IsObject(left)) {
            return left = right
        }

        for key, value in left.OwnProps() {
            if (!right.HasOwnProp(key) || !Matchers.deepEqual(value, right.%key%)) {
                return false
            }
        }

        for key in right.OwnProps() {
            if (!left.HasOwnProp(key)) {
                return false
            }
        }

        return true
    }
}
```

- [ ] **Step 6: Re-run the matcher tests**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\MatcherTests.ahk"`
Expected: PASS for the MVP matcher checks.

- [ ] **Step 7: Commit the matcher set**

```bash
git add src/assertions/Expectation.ahk src/assertions/Matchers.ahk tests/unit/MatcherTests.ahk
git commit -m "feat: add MVP matcher set"
```

### Task 6: Implement Suite Execution, Lifecycle Hooks, And Error Recording

**Files:**
- Modify: `src/core/SuiteRunner.ahk`
- Modify: `src/core/ExecutionContext.ahk`
- Modify: `src/core/Results.ahk`
- Modify: `tests/unit/SuiteRunnerTests.ahk`

- [ ] **Step 1: Write the failing runner tests for lifecycle order and continue-on-failure**

```ahk
#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

class OrderedSuite extends TestSuiteBase
{
    __New() {
        super.__New()
        this.log := []
    }

    beforeAll() {
        this.log.Push("beforeAll")
    }

    beforeEach() {
        this.log.Push("beforeEach")
    }

    sampleTest() {
        d := this.describe("Order")
        d.it("first failure").expect(1).toBe(2)
        d.it("second failure still runs").expect(3).toBe(4)
        this.log.Push("sampleTest")
    }

    afterEach() {
        this.log.Push("afterEach")
    }

    afterAll() {
        this.log.Push("afterAll")
    }
}

suite := OrderedSuite()
result := SuiteRunner.runSuiteInstance(suite)

if (suite.log.Join(",") != "beforeAll,beforeEach,sampleTest,afterEach,afterAll") {
    throw Error("Expected lifecycle hooks to run in order")
}

assertions := result.methods[1].describes[1].assertions
if (assertions.Length != 2) {
    throw Error("Expected both assertions to run by default")
}
```

- [ ] **Step 2: Run the suite runner test and verify it fails**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\SuiteRunnerTests.ahk"`
Expected: FAIL because suite execution is not implemented yet.

- [ ] **Step 3: Implement the suite execution flow**

```ahk
class SuiteRunner
{
    static runSuiteInstance(suite_instance) {
        suite_result := Results.newSuiteResult(suite_instance.__Class)
        context := ExecutionContext(suite_instance, suite_result, suite_instance.failFast)

        SuiteRunner.runHook(suite_instance, suite_result, "beforeAll")

        for method_name in SuiteRunner.discoverTestMethods(suite_instance) {
            SuiteRunner.runHook(suite_instance, suite_result, "beforeEach", method_name)

            method_result := context.beginMethod(method_name)
            suite_instance.__currentExecutionContext := context

            try {
                suite_instance.%method_name%()
            } catch as err {
                method_result.error := err.Message
            }

            suite_result.methods.Push(method_result)
            SuiteRunner.runHook(suite_instance, suite_result, "afterEach", method_name)
        }

        SuiteRunner.runHook(suite_instance, suite_result, "afterAll")
        Results.finalizeCounts(suite_result)
        return suite_result
    }
}
```

- [ ] **Step 4: Implement hook recording and aggregate counting**

```ahk
class SuiteRunner
{
    static runHook(suite_instance, suite_result, hook_name, method_name := "") {
        try {
            suite_instance.%hook_name%()
            suite_result.hooks.Push({ name: hook_name, method: method_name, passed: true, error: "" })
        } catch as err {
            suite_result.hooks.Push({ name: hook_name, method: method_name, passed: false, error: err.Message })
        }
    }
}

class Results
{
    static finalizeCounts(suite_result) {
        for method_result in suite_result.methods {
            for describe_result in method_result.describes {
                for assertion_result in describe_result.assertions {
                    if (assertion_result.error != "") {
                        suite_result.counts.errored += 1
                    } else if (assertion_result.passed) {
                        suite_result.counts.passed += 1
                    } else {
                        suite_result.counts.failed += 1
                    }
                }
            }
        }
    }
}
```

- [ ] **Step 5: Add a focused fail-fast precedence test**

```ahk
class FailFastSuite extends TestSuiteBase
{
    __New() {
        super.__New()
        this.failFast := false
    }

    sampleTest() {
        d := this.describe("Fail fast").failFast(true)
        d.it("stop here").failFast(true).expect(1).toBe(2)
        d.it("still recorded until stopping behavior is implemented").expect(3).toBe(4)
    }
}

suite := FailFastSuite()
result := SuiteRunner.runSuiteInstance(suite)
if (result.methods[1].describes[1].assertions[1].failFastSource != true) {
    throw Error("Expected assertion-level failFast override to win")
}
```

- [ ] **Step 6: Re-run the suite runner test**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\SuiteRunnerTests.ahk"`
Expected: PASS for hook order, default continue-on-failure, and fail-fast source precedence.

- [ ] **Step 7: Commit the suite execution core**

```bash
git add src/core/SuiteRunner.ahk src/core/ExecutionContext.ahk src/core/Results.ahk tests/unit/SuiteRunnerTests.ahk
git commit -m "feat: add suite execution and result aggregation"
```

### Task 7: Make Fail-Fast Actually Stop The Current Scope

**Files:**
- Modify: `src/core/ExecutionContext.ahk`
- Modify: `src/assertions/Expectation.ahk`
- Modify: `src/assertions/DescribeScope.ahk`
- Modify: `tests/unit/DescribeAndExpectationTests.ahk`

- [ ] **Step 1: Write the failing test for assertion-level fail-fast**

```ahk
#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

suite_result := Results.newSuiteResult("ExampleSuite")
context := ExecutionContext("", suite_result)
context.beginMethod("exampleTest")

d := DescribeScope(context, "Fail fast")
d.it("first").failFast(true).expect(1).toBe(2)
d.it("second").expect(3).toBe(4)

if (d.result.assertions.Length != 1) {
    throw Error("Expected fail-fast to stop additional assertions in the describe scope")
}
```

- [ ] **Step 2: Run the fail-fast test and verify it fails**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\DescribeAndExpectationTests.ahk"`
Expected: FAIL because both assertions are still recorded.

- [ ] **Step 3: Add scope stop state to the execution context**

```ahk
class ExecutionContext
{
    __New(suite_instance, suite_result, suite_fail_fast := false) {
        this.stoppedDescribeIds := Map()
    }

    stopDescribe(describe_id) {
        this.stoppedDescribeIds[describe_id] := true
    }

    isDescribeStopped(describe_id) {
        return this.stoppedDescribeIds.Has(describe_id)
    }
}
```

- [ ] **Step 4: Make describe and expectation honor stopped scopes**

```ahk
class DescribeScope
{
    __New(execution_context, description) {
        this.id := execution_context.currentMethod "::" description
    }

    it(description) {
        if (this.executionContext.isDescribeStopped(this.id)) {
            return AssertionCase(this, description, true)
        }

        return AssertionCase(this, description, false)
    }
}

class AssertionCase
{
    __New(describe_scope, description, skipped := false) {
        this.skipped := skipped
    }
}

class Expectation
{
    recordResult(matcher_name, passed, expected := "", message := "", error_text := "") {
        if (this.assertionCase.skipped) {
            return false
        }

        if (!passed && fail_fast) {
            describe_scope.executionContext.stopDescribe(describe_scope.id)
        }
    }
}
```

- [ ] **Step 5: Re-run the fail-fast test**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\DescribeAndExpectationTests.ahk"`
Expected: PASS with only the first failing assertion recorded.

- [ ] **Step 6: Commit the active fail-fast behavior**

```bash
git add src/core/ExecutionContext.ahk src/assertions/DescribeScope.ahk src/assertions/Expectation.ahk tests/unit/DescribeAndExpectationTests.ahk
git commit -m "feat: stop describe scope on fail-fast"
```

### Task 8: Add The CLI Renderer

**Files:**
- Create: `src/renderers/CliRenderer.ahk`
- Create: `tests/unit/CliRendererTests.ahk`

- [ ] **Step 1: Write the failing CLI renderer test**

```ahk
#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

result := {
    name: "ExampleSuite",
    hooks: [],
    methods: [{
        name: "sampleTest",
        describes: [{
            description: "Math checks",
            assertions: [{
                description: "adds numbers",
                matcher: "toBe",
                passed: false,
                expected: 4,
                actual: 5,
                message: "Expected 5 toBe 4",
                error: ""
            }]
        }]
    }],
    counts: { passed: 0, failed: 1, errored: 0 }
}

output := CliRenderer.render(result)
if (!InStr(output, "ExampleSuite") || !InStr(output, "adds numbers") || !InStr(output, "failed")) {
    throw Error("Expected CLI output to include suite, assertion, and failure status")
}
```

- [ ] **Step 2: Run the CLI renderer test and verify it fails**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\CliRendererTests.ahk"`
Expected: FAIL because `CliRenderer` does not exist yet.

- [ ] **Step 3: Implement a basic renderer that consumes normalized results only**

```ahk
class CliRenderer
{
    static render(suite_result) {
        lines := []
        lines.Push("Suite: " suite_result.name)

        for method_result in suite_result.methods {
            lines.Push("  Method: " method_result.name)

            for describe_result in method_result.describes {
                lines.Push("    Describe: " describe_result.description)

                for assertion_result in describe_result.assertions {
                    status := assertion_result.passed ? "passed" : "failed"
                    lines.Push("      [" status "] " assertion_result.description " (" assertion_result.matcher ")")

                    if (assertion_result.message != "") {
                        lines.Push("        " assertion_result.message)
                    }
                }
            }
        }

        lines.Push("Summary: " suite_result.counts.passed " passed, " suite_result.counts.failed " failed, " suite_result.counts.errored " errored")
        return CliRenderer.joinLines(lines)
    }

    static joinLines(lines) {
        output := ""

        for line in lines {
            output .= line "`n"
        }

        return RTrim(output, "`n")
    }
}
```

- [ ] **Step 4: Re-run the CLI renderer test**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\unit\CliRendererTests.ahk"`
Expected: PASS with failure details included in the rendered output.

- [ ] **Step 5: Commit the CLI renderer**

```bash
git add src/renderers/CliRenderer.ahk tests/unit/CliRendererTests.ahk
git commit -m "feat: add CLI renderer"
```

### Task 9: Add Functional Coverage For End-To-End MVP Flow

**Files:**
- Create: `tests/functional/MvpFlowTests.ahk`
- Modify: `README.md`

- [ ] **Step 1: Write the failing functional test for a realistic suite**

```ahk
#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

class MvpSuite extends TestSuiteBase
{
    sampleTest() {
        d := this.describe("Failing tests")

        x := 101
        d.it("x should equal 100").expect(x).toBe(100)

        x := { a: 10, b: "hello", c: { a: 20 } }
        y := { a: 10, b: "hello", c: { a: 30 } }
        d.it("x should be equal to y").expect(x).toEqual(y)

        d.it("throwing callback").expect(() => (throw Error("boom"))).toThrowError()
    }
}

result := SuiteRunner.runSuiteInstance(MvpSuite())
output := CliRenderer.render(result)

if (result.methods.Length != 1) {
    throw Error("Expected one discovered test method")
}

if (!InStr(output, "Failing tests") || !InStr(output, "x should equal 100")) {
    throw Error("Expected CLI output to include functional test details")
}
```

- [ ] **Step 2: Run the functional test and verify it fails**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\functional\MvpFlowTests.ahk"`
Expected: FAIL until all core pieces work together.

- [ ] **Step 3: Fill in the missing integration behavior discovered by the functional test**

```ahk
class Expectation
{
    recordResult(matcher_name, passed, expected := "", message := "", error_text := "") {
        if (message = "") {
            if (passed) {
                message := "Passed " matcher_name
            } else {
                message := "Expected " String(this.actual) " " matcher_name " " String(expected)
            }
        }

        describe_scope := this.assertionCase.describeScope
        fail_fast := describe_scope.executionContext.resolveFailFast(
            describe_scope.failFastOverride,
            this.assertionCase.failFastOverride
        )

        describe_scope.result.assertions.Push({
            description: this.assertionCase.description,
            matcher: matcher_name,
            actual: this.actual,
            expected: expected,
            passed: passed,
            message: message,
            failFastSource: fail_fast,
            error: error_text
        })

        if (!passed && fail_fast) {
            describe_scope.executionContext.stopDescribe(describe_scope.id)
        }

        return passed
    }
}
```

- [ ] **Step 4: Re-run the functional test**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\functional\MvpFlowTests.ahk"`
Expected: PASS with one suite, one method, three assertions, and readable CLI output.

- [ ] **Step 5: Document the MVP usage in `README.md`**

````md
# ahkxiom

An AutoHotkey v2 testing library.

## MVP Usage

```ahk
#Include src/Ahkxiom.ahk

class MySuite extends TestSuiteBase
{
    sampleTest() {
        d := this.describe("Math checks")
        d.it("adds numbers").expect(2 + 2).toBe(4)
    }
}

result := SuiteRunner.runSuiteInstance(MySuite())
MsgBox CliRenderer.render(result)
```
````

- [ ] **Step 6: Run the full development test runner**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\helpers\PlanTestRunner.ahk"`
Expected: all unit and functional test scripts run without failures.

- [ ] **Step 7: Commit the integration pass and docs**

```bash
git add tests/functional/MvpFlowTests.ahk README.md
git commit -m "feat: document and verify MVP flow"
```

### Task 10: Final Verification

**Files:**
- Verify: `src/Ahkxiom.ahk`
- Verify: `src/core/*.ahk`
- Verify: `src/assertions/*.ahk`
- Verify: `src/renderers/CliRenderer.ahk`
- Verify: `tests/unit/*.ahk`
- Verify: `tests/functional/MvpFlowTests.ahk`
- Verify: `README.md`

- [ ] **Step 1: Run the full test suite**

Run: `& "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe" "tests\helpers\PlanTestRunner.ahk"`
Expected: all included tests pass.

- [ ] **Step 2: Review the working tree**

Run: `git status --short`
Expected: only the intended source, test, and documentation files are modified or added.

- [ ] **Step 3: Review the implementation diff**

Run: `git diff -- src tests README.md`
Expected: diff matches the MVP design with no unrelated edits.

- [ ] **Step 4: Commit the final cleanup if needed**

```bash
git add src tests README.md
git commit -m "test: finalize MVP verification"
```
