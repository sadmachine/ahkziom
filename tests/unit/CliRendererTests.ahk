#Requires AutoHotkey v2.0
#Include ..\TestBootstrap.ahk

run_output := TestRunOutput("1.0", "run-1", "2026-05-19T00:00:00Z")
suite_output := SuiteOutput("ExampleSuite")
method_output := MethodOutput("sampleTest")
describe_output := DescribeOutput("Math checks")
describe_output.addAssertion(AssertionOutput("adds numbers", "toBe", 5, 4, false, "Expected 5 toBe 4", false, ""))
method_output.addDescribe(describe_output)
suite_output.addMethod(method_output)
suite_output.counts.failed := 1
run_output.addSuite(suite_output)
run_output.counts.failed := 1

output := CliRenderer().render(run_output)
if (!InStr(output, "ExampleSuite") || !InStr(output, "adds numbers") || !InStr(output, "failed")) {
    throw Error("Expected CLI output to render canonical output objects")
}

stream_file := A_Temp "\\ahkxiom-cli-renderer-test.txt"
if (FileExist(stream_file)) {
    FileDelete(stream_file)
}

stream_output := CliRenderer(stream_file).render(run_output)
written_output := FileRead(stream_file)

if (stream_output != output) {
    throw Error("Expected stream renderer to return rendered output")
}

if (RTrim(written_output, "`n`r") != output) {
    throw Error("Expected stream renderer to write rendered output")
}

FileDelete(stream_file)

ExitApp
