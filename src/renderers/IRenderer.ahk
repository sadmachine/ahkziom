#Requires AutoHotkey v2.0

class IRenderer
{
    render(test_run_output) {
        throw Error("Renderer implementations must provide render(test_run_output)")
    }
}
