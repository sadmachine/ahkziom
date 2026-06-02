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

suite_fail_fast_result := Results.newSuiteResult("SuiteFailFast")
suite_fail_fast_context := ExecutionContext({ failFast: true }, suite_fail_fast_result, true)
suite_fail_fast_context.beginMethod("suiteFailFastTest")
suite_fail_fast_describe := DescribeScope(suite_fail_fast_context, "Suite level fail-fast")
suite_fail_fast_describe.it("first failure").expect(1).toBe(2)
suite_fail_fast_describe.it("skipped after suite fail-fast").expect(3).toBe(3)

if (suite_fail_fast_describe.result.assertions.Length != 1) {
    throw Error("Expected suite-level fail-fast to skip later assertions in the same describe")
}

if (suite_fail_fast_describe.result.assertions[1].failFastSource != true) {
    throw Error("Expected suite-level fail-fast to be recorded on assertion output")
}

describe_fail_fast_result := Results.newSuiteResult("DescribeFailFast")
describe_fail_fast_context := ExecutionContext({ failFast: false }, describe_fail_fast_result, false)
describe_fail_fast_context.beginMethod("describeFailFastTest")
describe_fail_fast_scope := DescribeScope(describe_fail_fast_context, "Describe level fail-fast").failFast(true)
describe_fail_fast_scope.it("first failure").expect(1).toBe(2)
describe_fail_fast_scope.it("skipped after describe fail-fast").expect(3).toBe(3)

if (describe_fail_fast_scope.result.assertions.Length != 1) {
    throw Error("Expected describe-level fail-fast to skip later assertions in the same describe")
}

assertion_override_result := Results.newSuiteResult("AssertionOverride")
assertion_override_context := ExecutionContext({ failFast: true }, assertion_override_result, true)
assertion_override_context.beginMethod("assertionOverrideTest")
assertion_override_scope := DescribeScope(assertion_override_context, "Assertion override fail-fast")
assertion_override_scope.it("first failure keeps going").failFast(false).expect(1).toBe(2)
assertion_override_scope.it("second assertion runs").expect(3).toBe(3)

if (assertion_override_scope.result.assertions.Length != 2) {
    throw Error("Expected assertion-level fail-fast override to allow later assertions")
}

if (assertion_override_scope.result.assertions[1].failFastSource != false) {
    throw Error("Expected assertion-level fail-fast override to be recorded")
}

ExitApp
