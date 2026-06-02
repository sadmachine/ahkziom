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
        test_run_output := Results.newTestRunOutput(suite_instance.base.__Class)
        suite_output := Results.newSuiteOutput(suite_instance.base.__Class)
        test_run_output.addSuite(suite_output)
        context := ExecutionContext(suite_instance, suite_output, suite_instance.failFast)

        SuiteRunner.runHook(suite_instance, suite_output, "beforeAll")

        try {
            for method_name in SuiteRunner.discoverTestMethods(suite_instance) {
                SuiteRunner.runHook(suite_instance, suite_output, "beforeEach", method_name)

                method_result := context.beginMethod(method_name)
                suite_instance.__currentExecutionContext := context

                try {
                    suite_instance.%method_name%()
                } catch as err {
                    method_result.error := err.Message
                } finally {
                    suite_output.addMethod(method_result)
                    suite_instance.__currentExecutionContext := ""
                    SuiteRunner.runHook(suite_instance, suite_output, "afterEach", method_name)
                }
            }
        } finally {
            suite_instance.__currentExecutionContext := ""
            SuiteRunner.runHook(suite_instance, suite_output, "afterAll")
            Results.finalizeCounts(test_run_output)
        }

        return test_run_output
    }

    static runHook(suite_instance, suite_output, hook_name, method_name := "") {
        try {
            suite_instance.%hook_name%()
            suite_output.addHook(HookOutput(hook_name, method_name, true, ""))
        } catch as err {
            suite_output.addHook(HookOutput(hook_name, method_name, false, err.Message))
        }
    }
}
