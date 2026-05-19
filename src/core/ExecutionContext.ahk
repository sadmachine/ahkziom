#Requires AutoHotkey v2.0

class ExecutionContext
{
    __New(suite_instance, suite_output, suite_fail_fast := false) {
        this.suite := suite_instance
        this.suiteOutput := suite_output
        this.suiteFailFast := suite_fail_fast
        this.currentMethod := ""
        this.currentMethodResult := ""
        this.stoppedDescribeIds := Map()
    }

    beginMethod(method_name) {
        this.currentMethod := method_name
        this.currentMethodResult := Results.newMethodOutput(method_name)
        this.stoppedDescribeIds := Map()
        return this.currentMethodResult
    }

    resolveFailFast(describe_override := unset, assertion_override := unset) {
        if (IsSet(assertion_override)) {
            return assertion_override
        }

        if (IsSet(describe_override)) {
            return describe_override
        }

        return this.suiteFailFast
    }

    stopDescribe(describe_id) {
        this.stoppedDescribeIds[describe_id] := true
    }

    isDescribeStopped(describe_id) {
        return this.stoppedDescribeIds.Has(describe_id)
    }
}
