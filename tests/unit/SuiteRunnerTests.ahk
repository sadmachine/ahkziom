#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

suite_result := Results.newSuiteResult("ExampleSuite")
if (suite_result.name != "ExampleSuite") {
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

context := ExecutionContext("", suite_result)
context.beginMethod("exampleTest")
if (context.currentMethod != "exampleTest") {
    throw Error("Expected current method to be set")
}

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

ordered_suite := OrderedSuite()
run_result := SuiteRunner.runSuiteInstance(ordered_suite)
if (Type(run_result) != "TestRunOutput") {
    throw Error("Expected SuiteRunner to return TestRunOutput")
}

if (run_result.suites.Length != 1) {
    throw Error("Expected one suite output in the run output")
}

if (joinArray(ordered_suite.log, ",") != "beforeAll,beforeEach,sampleTest,afterEach,afterAll") {
    throw Error("Expected lifecycle hooks to run in order")
}

assertions := run_result.suites[1].methods[1].describes[1].assertions
if (assertions.Length != 2) {
    throw Error("Expected both assertions to run by default")
}

if (run_result.counts.failed != 2) {
    throw Error("Expected failed assertion count to be aggregated")
}

class ThrowingSuite extends TestSuiteBase
{
    __New() {
        super.__New()
        this.log := []
    }

    throwingTest() {
        this.log.Push("throwingTest")
        throw Error("method boom")
    }

    laterTest() {
        this.log.Push("laterTest")
        d := this.describe("Later")
        d.it("still runs").expect(1).toBe(1)
    }

    afterEach() {
        this.log.Push("afterEach")
    }
}

throwing_suite := ThrowingSuite()
throwing_run := SuiteRunner.runSuiteInstance(throwing_suite)

if (throwing_run.suites[1].methods.Length != 2) {
    throw Error("Expected both throwing and later test methods to be recorded")
}

if (!arrayHas(throwing_suite.log, "throwingTest") || !arrayHas(throwing_suite.log, "laterTest")) {
    throw Error("Expected throwing and later test methods to execute")
}

if (countArrayValue(throwing_suite.log, "afterEach") != 2) {
    throw Error("Expected throwing method cleanup and later method execution")
}

if (!methodErrorWasRecorded(throwing_run.suites[1].methods, "throwingTest", "method boom")) {
    throw Error("Expected throwing method error to be recorded")
}

if (!methodAssertionPassed(throwing_run.suites[1].methods, "laterTest")) {
    throw Error("Expected later method assertion to pass")
}

if (throwing_suite.__currentExecutionContext != "") {
    throw Error("Expected execution context to be cleared after suite run")
}

ExitApp

joinArray(values, separator) {
    joined := ""

    for value in values {
        joined .= (joined = "" ? "" : separator) value
    }

    return joined
}

arrayHas(values, expected) {
    for value in values {
        if (value = expected) {
            return true
        }
    }

    return false
}

countArrayValue(values, expected) {
    count := 0

    for value in values {
        if (value = expected) {
            count += 1
        }
    }

    return count
}

methodErrorWasRecorded(methods, method_name, error_text) {
    for method_output in methods {
        if (method_output.name = method_name && method_output.error = error_text) {
            return true
        }
    }

    return false
}

methodAssertionPassed(methods, method_name) {
    for method_output in methods {
        if (method_output.name = method_name) {
            return method_output.describes[1].assertions[1].passed
        }
    }

    return false
}
