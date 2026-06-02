#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

suite_result := Results.newSuiteResult("ExampleSuite")
context := ExecutionContext("", suite_result)
context.beginMethod("matcherTest")

d := DescribeScope(context, "Matchers")
d.it("toBe passes").expect(100).toBe(100)
d.it("toBeEmpty passes").expect("").toBeEmpty()
d.it("toBeTrue passes").expect(true).toBeTrue()
d.it("toBeFalse passes").expect(false).toBeFalse()
d.it("toHaveLength passes").expect([1, 2, 3]).toHaveLength(3)
d.it("toStartWith passes").expect("Hello World").toStartWith("Hello")
d.it("toEndWith passes").expect("Hello World").toEndWith("World")
d.it("toContain passes").expect("Hello World").toContain("World")
d.it("toThrowError passes").expect(() => throw Error("bad")).toThrowError()

x := 10
d.it("toBeDefined passes").expectVar(() => x).toBeDefined()
d.it("toBeUndefined passes").expectVar(undefinedAccessor).toBeUndefined()

assertions := d.result.assertions
if (assertions.Length != 11) {
    throw Error("Expected eleven matcher assertions")
}

for assertion_result in assertions {
    if (!assertion_result.passed) {
        throw Error("Expected matcher assertion to pass")
    }
}

usage_result := Results.newSuiteResult("UsageSuite")
usage_context := ExecutionContext("", usage_result)
usage_context.beginMethod("usageTest")
usage_describe := DescribeScope(usage_context, "Matcher usage errors")
usage_describe.it("toBeUndefined requires expectVar").expect("value").toBeUndefined()
usage_describe.it("toHaveLength requires length").expect(42).toHaveLength(1)

if (usage_describe.result.assertions.Length != 2) {
    throw Error("Expected two matcher usage assertions")
}

if (usage_describe.result.assertions[1].error != "NotVariableAccessor") {
    throw Error("Expected toBeUndefined usage error to be recorded")
}

if (usage_describe.result.assertions[2].error != "NoLength") {
    throw Error("Expected toHaveLength usage error to be recorded")
}

ExitApp

undefinedAccessor(value?) {
    return value
}
