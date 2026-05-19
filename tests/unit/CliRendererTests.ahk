#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

result := {
    name: "ExampleSuite",
    hooks: [],
    methods: [{
        name: "sampleTest",
        describes: [{
            description: "Math checks",
            assertions: [{
                description: "adds numbers",
                matcher: "toBe",
                passed: false,
                expected: 4,
                actual: 5,
                message: "Expected 5 toBe 4",
                error: ""
            }]
        }]
    }],
    counts: { passed: 0, failed: 1, errored: 0 }
}

output := CliRenderer.render(result)
if (!InStr(output, "ExampleSuite") || !InStr(output, "adds numbers") || !InStr(output, "failed")) {
    throw Error("Expected CLI output to include suite, assertion, and failure status")
}

ExitApp
