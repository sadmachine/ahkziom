#Requires AutoHotkey v2.0

class CliRenderer extends IRenderer
{
    __New(output_stream := "") {
        this.outputStream := output_stream
    }

    render(test_run_output) {
        lines := []
        lines.Push("Run: " test_run_output.runId " (schema " test_run_output.schemaVersion ")")

        for suite_output in test_run_output.suites {
            lines.Push("Suite: " suite_output.name)

            for hook_output in suite_output.hooks {
                if (!hook_output.passed) {
                    hook_label := hook_output.method = "" ? hook_output.name : hook_output.name " for " hook_output.method
                    lines.Push("  Hook failed: " hook_label)
                    lines.Push("    " hook_output.error)
                }
            }

            for method_output in suite_output.methods {
                lines.Push("  Method: " method_output.name)

                if (method_output.error != "") {
                    lines.Push("    Error: " method_output.error)
                }

                for describe_output in method_output.describes {
                    lines.Push("    Describe: " describe_output.description)

                    for assertion_output in describe_output.assertions {
                        status := assertion_output.passed ? "passed" : "failed"
                        lines.Push("      [" status "] " assertion_output.description " (" assertion_output.matcher ")")

                        if (assertion_output.message != "") {
                            lines.Push("        " assertion_output.message)
                        }

                        if (assertion_output.error != "") {
                            lines.Push("        Error: " assertion_output.error)
                        }
                    }
                }
            }
        }

        lines.Push("Summary: " test_run_output.counts.passed " passed, " test_run_output.counts.failed " failed, " test_run_output.counts.errored " errored")
        output := CliRenderer.joinLines(lines)
        if (this.outputStream != "") {
            FileAppend(output "`n", this.outputStream)
        }

        return output
    }

    static joinLines(lines) {
        output := ""

        for line in lines {
            output .= line "`n"
        }

        return RTrim(output, "`n")
    }
}
