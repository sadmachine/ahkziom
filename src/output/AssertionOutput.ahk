#Requires AutoHotkey v2.0

class AssertionOutput
{
    __New(description, matcher_name, actual_value, expected_value, passed, message := "", fail_fast_source := false, error_text := "") {
        this.description := description
        this.matcher := matcher_name
        this.actual := actual_value
        this.expected := expected_value
        this.passed := passed
        this.message := message
        this.failFastSource := fail_fast_source
        this.error := error_text
    }
}
