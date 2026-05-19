#Requires AutoHotkey v2.0

class DescribeScope
{
    __New(execution_context, description) {
        this.executionContext := execution_context
        this.description := description
        this.hasFailFastOverride := false
        this.failFastOverride := false
        this.id := description
        this.result := Results.newDescribeOutput(description, false)

        if (IsObject(execution_context) && execution_context.currentMethodResult != "") {
            this.id := execution_context.currentMethod "::" description
            execution_context.currentMethodResult.addDescribe(this.result)
        }
    }

    failFast(enabled := true) {
        this.hasFailFastOverride := true
        this.failFastOverride := enabled
        this.result.failFast := enabled
        return this
    }

    it(description) {
        if (IsObject(this.executionContext) && this.executionContext.isDescribeStopped(this.id)) {
            return AssertionCase(this, description, true)
        }

        return AssertionCase(this, description)
    }
}
