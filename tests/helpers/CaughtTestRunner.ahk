#Requires AutoHotkey v2.0

if (A_Args.Length < 1) {
    FileAppend("Usage: CaughtTestRunner.ahk <test-file>`n", "*")
    ExitApp 1
}

test_file := A_Args[1]
if (!FileExist(test_file)) {
    FileAppend("Test file not found: " test_file "`n", "*")
    ExitApp 1
}

wrapper_file := A_Temp "\\ahkxiom-caught-test-" A_TickCount ".ahk"
result_file := A_Temp "\\ahkxiom-caught-test-" A_TickCount ".txt"
wrapper_content := "#Requires AutoHotkey v2.0`n"
wrapper_content .= "try {`n"
wrapper_content .= "#Include " quote(test_file) "`n"
wrapper_content .= "} catch as err {`n"
wrapper_content .= '    FileAppend("Error: " err.Message "``n", ' quote(result_file) ')`n'
wrapper_content .= '    FileAppend("File: " err.File "``n", ' quote(result_file) ')`n'
wrapper_content .= '    FileAppend("Line: " err.Line "``n", ' quote(result_file) ')`n'
wrapper_content .= "    ExitApp 1`n"
wrapper_content .= "}`n"
wrapper_content .= "ExitApp 0`n"

FileAppend(wrapper_content, wrapper_file)
exit_code := RunWait('"' A_AhkPath '" /ErrorStdOut "' wrapper_file '"')
FileDelete(wrapper_file)
if (FileExist(result_file)) {
    FileAppend(FileRead(result_file), "*")
    FileDelete(result_file)
}
ExitApp exit_code

quote(value) {
    return '"' StrReplace(value, '"', '""') '"'
}
