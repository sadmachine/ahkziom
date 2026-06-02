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

        assertion_output := AssertionOutput(
            this.assertionCase.description,
            matcher_name,
            this.hasActualValue ? this.actual : "",
            expected,
            passed,
            message,
            fail_fast,
            error_text
        )
        describe_scope.result.addAssertion(assertion_output)

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

    toBeTrue() {
        return Matchers.toBeTrue(this)
    }

    toBeFalse() {
        return Matchers.toBeFalse(this)
    }

    toBeDefined() {
        return Matchers.toBeDefined(this)
    }

    toBeUndefined() {
        return Matchers.toBeUndefined(this)
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

    toHaveLength(expected) {
        return Matchers.toHaveLength(this, expected)
    }

    toStartWith(expected) {
        return Matchers.toStartWith(this, expected)
    }

    toEndWith(expected) {
        return Matchers.toEndWith(this, expected)
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
