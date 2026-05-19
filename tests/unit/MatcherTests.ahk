#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

suite_result := Results.newSuiteResult("ExampleSuite")
context := ExecutionContext("", suite_result)
context.beginMethod("matcherTest")

d := DescribeScope(context, "Matchers")
d.it("toBe passes").expect(100).toBe(100)
d.it("toBeEmpty passes").expect("").toBeEmpty()
d.it("toContain passes").expect("Hello World").toContain("World")
d.it("toThrowError passes").expect(() => throw Error("bad")).toThrowError()

x := 10
d.it("toBeDefined passes").expectVar(() => x).toBeDefined()

assertions := d.result.assertions
if (assertions.Length != 5) {
    throw Error("Expected five matcher assertions")
}

for assertion_result in assertions {
    if (!assertion_result.passed) {
        throw Error("Expected matcher assertion to pass")
    }
}

ExitApp
