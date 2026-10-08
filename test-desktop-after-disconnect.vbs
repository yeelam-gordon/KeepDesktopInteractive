Dim shell, folder, command
Set shell = CreateObject("WScript.Shell")
folder = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
command = """" & shell.ExpandEnvironmentStrings("%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe") & """ -STA -NoProfile -NonInteractive -ExecutionPolicy Bypass -File """ & folder & "\Test-InteractiveDesktopAutomation.ps1"""
If WScript.Arguments.Count > 0 Then
    Select Case WScript.Arguments(0)
        Case "--connected-smoke-test"
            command = command & " -ConnectedSmokeTest"
        Case "--minimized-test"
            command = command & " -MinimizedTest"
        Case "--installed"
            command = command & " -RequireInstalledSetup"
        Case Else
            WScript.Quit 2
    End Select
End If
WScript.Quit shell.Run(command, 0, True)
