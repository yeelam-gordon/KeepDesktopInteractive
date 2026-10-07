Dim shell, folder, command
Set shell = CreateObject("WScript.Shell")
folder = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
command = "powershell.exe -STA -NoProfile -NonInteractive -ExecutionPolicy Bypass -File """ & folder & "\Test-DesktopAfterDisconnect.ps1"""
If WScript.Arguments.Count > 0 Then
    Select Case WScript.Arguments(0)
        Case "--connected-smoke-test"
            command = command & " -ConnectedSmokeTest"
        Case "--minimized-test"
            command = command & " -MinimizedTest"
        Case Else
            WScript.Quit 2
    End Select
End If
WScript.Quit shell.Run(command, 0, True)
