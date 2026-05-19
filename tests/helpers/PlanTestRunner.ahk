#Requires AutoHotkey v2.0

#Include ..\TestBootstrap.ahk

test_files := [
    A_ScriptDir "\\..\\unit\\TestSuiteBaseTests.ahk",
    A_ScriptDir "\\..\\unit\\DescribeAndExpectationTests.ahk",
    A_ScriptDir "\\..\\unit\\MatcherTests.ahk",
    A_ScriptDir "\\..\\unit\\SuiteRunnerTests.ahk",
    A_ScriptDir "\\..\\unit\\CliRendererTests.ahk",
    A_ScriptDir "\\..\\functional\\MvpFlowTests.ahk"
]

for test_file in test_files {
    if (FileExist(test_file)) {
        RunWait('"' A_AhkPath '" /ErrorStdOut "' test_file '"')
    }
}
