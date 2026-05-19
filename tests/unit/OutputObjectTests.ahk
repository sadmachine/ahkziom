#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

run_output := TestRunOutput("1.0", "run-1", "2026-05-19T00:00:00Z")
if (run_output.schemaVersion != "1.0") {
    throw Error("Expected schemaVersion to be recorded")
}

suite_output := SuiteOutput("ExampleSuite")
run_output.addSuite(suite_output)
if (run_output.suites.Length != 1) {
    throw Error("Expected suite to be added to the run output")
}

counts := CountOutput()
counts.failed := 2
if (counts.failed != 2) {
    throw Error("Expected count output to store counts")
}

ExitApp
