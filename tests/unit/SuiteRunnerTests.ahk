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

ExitApp

joinArray(values, separator) {
    joined := ""

    for value in values {
        joined .= (joined = "" ? "" : separator) value
    }

    return joined
}
