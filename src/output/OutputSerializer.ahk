#Requires AutoHotkey v2.0

class OutputSerializer
{
    static toPortable(test_run_output) {
        suites := []

        for suite_output in test_run_output.suites {
            suites.Push(OutputSerializer.suiteToPortable(suite_output))
        }

        return {
            schemaVersion: test_run_output.schemaVersion,
            runId: test_run_output.runId,
            createdAt: test_run_output.createdAt,
            metadata: test_run_output.metadata,
            counts: OutputSerializer.countsToPortable(test_run_output.counts),
            suites: suites
        }
    }

    static suiteToPortable(suite_output) {
        hooks := []
        methods := []

        for hook_output in suite_output.hooks {
            hooks.Push({
                name: hook_output.name,
                method: hook_output.method,
                passed: hook_output.passed,
                error: hook_output.error
            })
        }

        for method_output in suite_output.methods {
            methods.Push(OutputSerializer.methodToPortable(method_output))
        }

        return {
            name: suite_output.name,
            metadata: suite_output.metadata,
            hooks: hooks,
            methods: methods,
            counts: OutputSerializer.countsToPortable(suite_output.counts)
        }
    }

    static methodToPortable(method_output) {
        describes := []

        for describe_output in method_output.describes {
            describes.Push(OutputSerializer.describeToPortable(describe_output))
        }

        return {
            name: method_output.name,
            describes: describes,
            error: method_output.error,
            durationMs: method_output.durationMs
        }
    }

    static describeToPortable(describe_output) {
        assertions := []

        for assertion_output in describe_output.assertions {
            assertions.Push({
                description: assertion_output.description,
                matcher: assertion_output.matcher,
                actual: assertion_output.actual,
                expected: assertion_output.expected,
                passed: assertion_output.passed,
                message: assertion_output.message,
                failFastSource: assertion_output.failFastSource,
                error: assertion_output.error
            })
        }

        return {
            description: describe_output.description,
            failFast: describe_output.failFast,
            assertions: assertions
        }
    }

    static countsToPortable(count_output) {
        return {
            passed: count_output.passed,
            failed: count_output.failed,
            errored: count_output.errored
        }
    }
}
