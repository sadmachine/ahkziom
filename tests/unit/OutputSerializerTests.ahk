#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

run_output := TestRunOutput("1.0", "run-1", "2026-05-19T00:00:00Z")
suite_output := SuiteOutput("ExampleSuite")
run_output.addSuite(suite_output)

portable := OutputSerializer.toPortable(run_output)
if (portable.schemaVersion != "1.0") {
    throw Error("Expected portable output to preserve schemaVersion")
}

if (portable.suites.Length != 1) {
    throw Error("Expected portable output to include suites")
}

ExitApp
