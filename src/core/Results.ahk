#Requires AutoHotkey v2.0

class Results
{
    static newTestRunOutput(suite_name) {
        return TestRunOutput("1.0", "run-" A_NowUTC, A_NowUTC)
    }

    static newSuiteOutput(name) {
        return SuiteOutput(name)
    }

    static newMethodOutput(name) {
        return MethodOutput(name)
    }

    static newDescribeOutput(description, fail_fast) {
        return DescribeOutput(description, fail_fast)
    }

    static newSuiteResult(name) {
        return Results.newSuiteOutput(name)
    }

    static newMethodResult(name) {
        return Results.newMethodOutput(name)
    }

    static newDescribeResult(description, fail_fast) {
        return Results.newDescribeOutput(description, fail_fast)
    }

    static finalizeCounts(test_run_output) {
        if (test_run_output.HasOwnProp("suites")) {
            test_run_output.counts := CountOutput()

            for suite_output in test_run_output.suites {
                Results.finalizeSuiteCounts(suite_output)
                test_run_output.counts.passed += suite_output.counts.passed
                test_run_output.counts.failed += suite_output.counts.failed
                test_run_output.counts.errored += suite_output.counts.errored
            }

            return test_run_output.counts
        }

        return Results.finalizeSuiteCounts(test_run_output)
    }

    static finalizeSuiteCounts(suite_output) {
        suite_output.counts := CountOutput()

        for method_output in suite_output.methods {
            for describe_output in method_output.describes {
                for assertion_output in describe_output.assertions {
                    if (assertion_output.error != "") {
                        suite_output.counts.errored += 1
                    } else if (assertion_output.passed) {
                        suite_output.counts.passed += 1
                    } else {
                        suite_output.counts.failed += 1
                    }
                }
            }
        }

        return suite_output.counts
    }
}
