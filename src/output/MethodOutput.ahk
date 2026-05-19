#Requires AutoHotkey v2.0

class MethodOutput
{
    __New(name) {
        this.name := name
        this.describes := []
        this.error := ""
        this.durationMs := 0
    }

    addDescribe(describe_output) {
        this.describes.Push(describe_output)
        return describe_output
    }
}
