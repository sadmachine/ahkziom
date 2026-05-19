#Requires AutoHotkey v2.0

class DescribeOutput
{
    __New(description, fail_fast := false) {
        this.description := description
        this.failFast := fail_fast
        this.assertions := []
    }

    addAssertion(assertion_output) {
        this.assertions.Push(assertion_output)
        return assertion_output
    }
}
