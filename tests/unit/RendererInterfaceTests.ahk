#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

if (!HasMethod(CliRenderer.Prototype, "render")) {
    throw Error("Expected CliRenderer to expose instance render()")
}

if (!HasMethod(IRenderer.Prototype, "render")) {
    throw Error("Expected IRenderer to define a render contract")
}

ExitApp
