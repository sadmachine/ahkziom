#Requires AutoHotkey v2.0

class HookOutput
{
    __New(name, method_name := "", passed := true, error_text := "") {
        this.name := name
        this.method := method_name
        this.passed := passed
        this.error := error_text
    }
}
