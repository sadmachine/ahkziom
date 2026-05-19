#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

suite_output := SuiteOutput("ExampleSuite")
context := ExecutionContext("", suite_output)
context.beginMethod("exampleTest")

d := DescribeScope(context, "Numbers")
assertion_case := d.it("adds numbers")
expectation_obj := assertion_case.expect(4)

if (assertion_case.description != "adds numbers") {
    throw Error("Expected it() to capture the assertion description")
}

if (expectation_obj.actual != 4) {
    throw Error("Expected expect() to capture the actual value")
}

suite_output := SuiteOutput("ExampleSuite")
context := ExecutionContext("", suite_output)
context.beginMethod("failFastTest")

d := DescribeScope(context, "Fail fast")
d.it("first").failFast(true).expect(1).toBe(2)
d.it("second").expect(3).toBe(4)

if (d.result.assertions.Length != 1) {
    throw Error("Expected fail-fast to stop additional assertions in the describe scope")
}

assertion_output := d.result.assertions[1]
if (Type(assertion_output) != "AssertionOutput") {
    throw Error("Expected canonical assertion output object")
}

ExitApp
