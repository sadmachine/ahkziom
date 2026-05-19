#Requires AutoHotkey v2.0

class SuiteOutput
{
    __New(name) {
        this.name := name
        this.metadata := Map()
        this.hooks := []
        this.methods := []
        this.counts := CountOutput()
    }

    addHook(hook_output) {
        this.hooks.Push(hook_output)
        return hook_output
    }

    addMethod(method_output) {
        this.methods.Push(method_output)
        return method_output
    }
}
