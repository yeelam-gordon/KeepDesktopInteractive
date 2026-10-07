Dim shell, folder, command
Set shell = CreateObject("WScript.Shell")
folder = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
command = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File """ & folder & "\Launch-DesktopSessionSetup.ps1"""
If WScript.Arguments.Count > 0 Then
    Select Case WScript.Arguments(0)
        Case "--uninstall"
            command = command & " -Uninstall"
        Case Else
            WScript.Quit 2
    End Select
End If
WScript.Quit shell.Run(command, 0, True)
