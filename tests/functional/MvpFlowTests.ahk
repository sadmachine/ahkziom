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

        d.it("throwing callback").expect(callbackBoom).toThrowError()
    }
}

result := SuiteRunner.runSuiteInstance(MvpSuite())
output := CliRenderer.render(result)

if (result.methods.Length != 1) {
    throw Error("Expected one discovered test method")
}

if (result.methods[1].describes[1].assertions.Length != 3) {
    throw Error("Expected three assertions in the functional suite")
}

if (!InStr(output, "Failing tests") || !InStr(output, "x should equal 100")) {
    throw Error("Expected CLI output to include functional test details")
}

ExitApp

callbackBoom() {
    throw Error("boom")
}
