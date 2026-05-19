#Requires AutoHotkey v2.0

class Expectation
{
    __New(assertion_case, actual?, value_factory := "") {
        this.assertionCase := assertion_case
        this.valueFactory := value_factory

        if (IsSet(actual)) {
            this.actual := actual
            this.hasActualValue := true
        } else {
            this.actual := ""
            this.hasActualValue := false
        }
    }

    recordResult(matcher_name, passed, expected := "", message := "", error_text := "") {
        if (this.assertionCase.skipped) {
            return false
        }

        describe_scope := this.assertionCase.describeScope
        describe_override_is_set := describe_scope.hasFailFastOverride
        assertion_override_is_set := this.assertionCase.hasFailFastOverride

        if (assertion_override_is_set) {
            fail_fast := describe_scope.executionContext.resolveFailFast("", this.assertionCase.failFastOverride)
        } else if (describe_override_is_set) {
            fail_fast := describe_scope.executionContext.resolveFailFast(describe_scope.failFastOverride)
        } else {
            fail_fast := describe_scope.executionContext.resolveFailFast()
        }

        describe_scope.result.assertions.Push({
            description: this.assertionCase.description,
            matcher: matcher_name,
            actual: this.hasActualValue ? this.actual : "",
            expected: expected,
            passed: passed,
            message: message,
            failFastSource: fail_fast,
            error: error_text
        })

        if (!passed && fail_fast) {
            describe_scope.executionContext.stopDescribe(describe_scope.id)
        }

        return passed
    }

    toBe(expected) {
        return Matchers.toBe(this, expected)
    }

    toEqual(expected) {
        return Matchers.toEqual(this, expected)
    }

    toBeTruthy() {
        return Matchers.toBeTruthy(this)
    }

    toBeFalsy() {
        return Matchers.toBeFalsy(this)
    }

    toBeDefined() {
        return Matchers.toBeDefined(this)
    }

    toBeEmpty() {
        return Matchers.toBeEmpty(this)
    }

    toBeLessThan(expected) {
        return Matchers.toBeLessThan(this, expected)
    }

    toBeGreaterThan(expected) {
        return Matchers.toBeGreaterThan(this, expected)
    }

    toContain(expected) {
        return Matchers.toContain(this, expected)
    }

    toMatch(pattern) {
        return Matchers.toMatch(this, pattern)
    }

    toThrowError(error_class_name := "") {
        return Matchers.toThrowError(this, error_class_name)
    }
}
