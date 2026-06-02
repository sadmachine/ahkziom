#Requires AutoHotkey v2.0

#Include ..\TestBootstrap.ahk

test_files := [
    A_ScriptDir "\\..\\unit\\TestSuiteBaseTests.ahk",
    A_ScriptDir "\\..\\unit\\DescribeAndExpectationTests.ahk",
    A_ScriptDir "\\..\\unit\\MatcherTests.ahk",
    A_ScriptDir "\\..\\unit\\OutputObjectTests.ahk",
    A_ScriptDir "\\..\\unit\\OutputSerializerTests.ahk",
    A_ScriptDir "\\..\\unit\\RendererInterfaceTests.ahk",
    A_ScriptDir "\\..\\unit\\SuiteRunnerTests.ahk",
    A_ScriptDir "\\..\\unit\\CliRendererTests.ahk",
    A_ScriptDir "\\..\\functional\\MvpFlowTests.ahk"
]

failed_files := []

for test_file in test_files {
    if (FileExist(test_file)) {
        FileAppend("Running " test_file "`n", "*")
        exit_code := RunWait('"' A_AhkPath '" /ErrorStdOut "' test_file '"')
        if (exit_code != 0) {
            failed_files.Push(test_file)
        }
    }
}

if (failed_files.Length > 0) {
    FileAppend("Failed test files:`n", "*")
    for failed_file in failed_files {
        FileAppend("- " failed_file "`n", "*")
    }
    ExitApp 1
}

FileAppend("All test files passed.`n", "*")
ExitApp 0
