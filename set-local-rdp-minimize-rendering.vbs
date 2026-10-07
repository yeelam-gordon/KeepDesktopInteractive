Dim shell, folder, command
Set shell = CreateObject("WScript.Shell")
folder = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
command = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File """ & folder & "\Set-LocalRdpMinimizeRendering.ps1"""
If WScript.Arguments.Count > 0 Then
    If WScript.Arguments(0) <> "--restore" Then WScript.Quit 2
    command = command & " -Restore"
End If
WScript.Quit shell.Run(command, 0, True)
