#Requires AutoHotkey v2.0

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
