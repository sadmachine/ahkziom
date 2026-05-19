#Requires AutoHotkey v2.0

class SuiteRunner
{
    static reservedMethodNames := Map(
        "__New", true,
        "describe", true,
        "beforeAll", true,
        "afterAll", true,
        "beforeEach", true,
        "afterEach", true
    )

    static discoverTestMethods(suite_instance) {
        methods := []
        prototype := suite_instance.base

        for method_name in prototype.OwnProps() {
            if (SubStr(method_name, 1, 1) = "_") {
                continue
            }

            if (SuiteRunner.reservedMethodNames.Has(method_name)) {
                continue
            }

            if (HasMethod(suite_instance, method_name)) {
                methods.Push(method_name)
            }
        }

        return methods
    }

    static runSuiteInstance(suite_instance) {
        suite_result := Results.newSuiteResult(suite_instance.base.__Class)
        context := ExecutionContext(suite_instance, suite_result, suite_instance.failFast)

        SuiteRunner.runHook(suite_instance, suite_result, "beforeAll")

        for method_name in SuiteRunner.discoverTestMethods(suite_instance) {
            SuiteRunner.runHook(suite_instance, suite_result, "beforeEach", method_name)

            method_result := context.beginMethod(method_name)
            suite_instance.__currentExecutionContext := context

            try {
                suite_instance.%method_name%()
            } catch as err {
                method_result.error := err.Message
            }

            suite_result.methods.Push(method_result)
            SuiteRunner.runHook(suite_instance, suite_result, "afterEach", method_name)
        }

        SuiteRunner.runHook(suite_instance, suite_result, "afterAll")
        Results.finalizeCounts(suite_result)
        return suite_result
    }

    static runHook(suite_instance, suite_result, hook_name, method_name := "") {
        try {
            suite_instance.%hook_name%()
            suite_result.hooks.Push({ name: hook_name, method: method_name, passed: true, error: "" })
        } catch as err {
            suite_result.hooks.Push({ name: hook_name, method: method_name, passed: false, error: err.Message })
        }
    }
}
