#Requires AutoHotkey v2.0

class Results
{
    static newSuiteResult(name) {
        return {
            name: name,
            config: Map(),
            hooks: [],
            methods: [],
            counts: { passed: 0, failed: 0, errored: 0 }
        }
    }

    static newMethodResult(name) {
        return {
            name: name,
            describes: [],
            error: "",
            durationMs: 0
        }
    }

    static newDescribeResult(description, fail_fast) {
        return {
            description: description,
            failFast: fail_fast,
            assertions: []
        }
    }

    static finalizeCounts(suite_result) {
        suite_result.counts := { passed: 0, failed: 0, errored: 0 }

        for method_result in suite_result.methods {
            for describe_result in method_result.describes {
                for assertion_result in describe_result.assertions {
                    if (assertion_result.error != "") {
                        suite_result.counts.errored += 1
                    } else if (assertion_result.passed) {
                        suite_result.counts.passed += 1
                    } else {
                        suite_result.counts.failed += 1
                    }
                }
            }
        }

        return suite_result.counts
    }
}
