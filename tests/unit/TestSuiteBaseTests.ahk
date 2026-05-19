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

ExitApp
