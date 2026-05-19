#Requires AutoHotkey v2.0

class CliRenderer
{
    static render(suite_result) {
        lines := []
        lines.Push("Suite: " suite_result.name)

        for method_result in suite_result.methods {
            lines.Push("  Method: " method_result.name)

            for describe_result in method_result.describes {
                lines.Push("    Describe: " describe_result.description)

                for assertion_result in describe_result.assertions {
                    status := assertion_result.passed ? "passed" : "failed"
                    lines.Push("      [" status "] " assertion_result.description " (" assertion_result.matcher ")")

                    if (assertion_result.message != "") {
                        lines.Push("        " assertion_result.message)
                    }
                }
            }
        }

        lines.Push("Summary: " suite_result.counts.passed " passed, " suite_result.counts.failed " failed, " suite_result.counts.errored " errored")
        return CliRenderer.joinLines(lines)
    }

    static joinLines(lines) {
        output := ""

        for line in lines {
            output .= line "`n"
        }

        return RTrim(output, "`n")
    }
}
