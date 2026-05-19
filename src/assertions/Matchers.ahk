#Requires AutoHotkey v2.0

class Matchers
{
    static toBe(expectation_obj, expected) {
        passed := expectation_obj.actual = expected
        message := passed ? "" : "Expected " Matchers.valueText(expectation_obj.actual) " toBe " Matchers.valueText(expected)
        return expectation_obj.recordResult("toBe", passed, expected, message)
    }

    static toEqual(expectation_obj, expected) {
        passed := Matchers.deepEqual(expectation_obj.actual, expected)
        message := passed ? "" : "Expected values to be deeply equal"
        return expectation_obj.recordResult("toEqual", passed, expected, message)
    }

    static toBeTruthy(expectation_obj) {
        passed := !!expectation_obj.actual
        message := passed ? "" : "Expected value to be truthy"
        return expectation_obj.recordResult("toBeTruthy", passed, "", message)
    }

    static toBeFalsy(expectation_obj) {
        passed := !expectation_obj.actual
        message := passed ? "" : "Expected value to be falsy"
        return expectation_obj.recordResult("toBeFalsy", passed, "", message)
    }

    static toBeDefined(expectation_obj) {
        value_factory := expectation_obj.valueFactory
        if (!HasMethod(value_factory, "Call")) {
            return expectation_obj.recordResult("toBeDefined", false, "", "Expected a callable variable accessor", "NotCallable")
        }

        try {
            value_factory.Call()
            passed := true
            message := ""
        } catch UnsetError as _ {
            passed := false
            message := "Expected variable to be defined"
        }

        return expectation_obj.recordResult("toBeDefined", passed, "", message)
    }

    static toBeEmpty(expectation_obj) {
        passed := expectation_obj.actual = ""
        message := passed ? "" : "Expected value to be empty"
        return expectation_obj.recordResult("toBeEmpty", passed, "", message)
    }

    static toBeLessThan(expectation_obj, expected) {
        passed := expectation_obj.actual < expected
        message := passed ? "" : "Expected value to be less than " Matchers.valueText(expected)
        return expectation_obj.recordResult("toBeLessThan", passed, expected, message)
    }

    static toBeGreaterThan(expectation_obj, expected) {
        passed := expectation_obj.actual > expected
        message := passed ? "" : "Expected value to be greater than " Matchers.valueText(expected)
        return expectation_obj.recordResult("toBeGreaterThan", passed, expected, message)
    }

    static toContain(expectation_obj, expected) {
        passed := InStr(expectation_obj.actual, expected) > 0
        message := passed ? "" : "Expected value to contain " Matchers.valueText(expected)
        return expectation_obj.recordResult("toContain", passed, expected, message)
    }

    static toMatch(expectation_obj, pattern) {
        passed := RegExMatch(expectation_obj.actual, pattern) > 0
        message := passed ? "" : "Expected value to match " Matchers.valueText(pattern)
        return expectation_obj.recordResult("toMatch", passed, pattern, message)
    }

    static toThrowError(expectation_obj, error_class_name := "") {
        callback := expectation_obj.actual
        if (!HasMethod(callback, "Call")) {
            return expectation_obj.recordResult("toThrowError", false, error_class_name, "Expected a callable value", "NotCallable")
        }

        try {
            callback.Call()
            return expectation_obj.recordResult("toThrowError", false, error_class_name, "Expected callback to throw")
        } catch as err {
            if (error_class_name = "") {
                return expectation_obj.recordResult("toThrowError", true, error_class_name)
            }

            passed := err.__Class = error_class_name
            message := passed ? "" : "Expected thrown error class to be " error_class_name
            return expectation_obj.recordResult("toThrowError", passed, error_class_name, message)
        }
    }

    static deepEqual(left, right) {
        if (Type(left) != Type(right)) {
            return false
        }

        if (!IsObject(left)) {
            return left = right
        }

        for key in left.OwnProps() {
            if (!right.HasOwnProp(key)) {
                return false
            }

            if (!Matchers.deepEqual(left.%key%, right.%key%)) {
                return false
            }
        }

        for key in right.OwnProps() {
            if (!left.HasOwnProp(key)) {
                return false
            }
        }

        return true
    }

    static valueText(value) {
        if (IsObject(value)) {
            return Type(value)
        }

        return String(value)
    }
}
