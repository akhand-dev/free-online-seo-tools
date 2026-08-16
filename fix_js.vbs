Option Explicit
Dim fso, projectRoot
Set fso = CreateObject("Scripting.FileSystemObject")
projectRoot = fso.GetParentFolderName(WScript.ScriptFullName)

Function ReadUTF8(filePath)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.CharSet = "utf-8"
    stream.Open
    stream.LoadFromFile filePath
    ReadUTF8 = stream.ReadText()
    stream.Close
End Function

Sub WriteUTF8(filePath, content)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.CharSet = "utf-8"
    stream.Open
    stream.WriteText content
    stream.SaveToFile filePath, 2
    stream.Close
End Sub

' Regex for main.js tools array
Dim regJS
Set regJS = CreateObject("VBScript.RegExp")
regJS.Global = True
regJS.Pattern = "url:\s*""([^""]+)\.html"""

' Regex for sw.js cache
Dim regSW
Set regSW = CreateObject("VBScript.RegExp")
regSW.Global = True
regSW.Pattern = "'/index\.html'"

' Update main.js
Dim mainJsPath, content, original
mainJsPath = projectRoot & "\js\main.js"
If fso.FileExists(mainJsPath) Then
    content = ReadUTF8(mainJsPath)
    original = content
    content = regJS.Replace(content, "url: ""$1""")
    If content <> original Then
        WriteUTF8 mainJsPath, content
    End If
End If

' Update sw.js
Dim swJsPath
swJsPath = projectRoot & "\sw.js"
If fso.FileExists(swJsPath) Then
    content = ReadUTF8(swJsPath)
    original = content
    content = regSW.Replace(content, "'/'")
    If content <> original Then
        WriteUTF8 swJsPath, content
    End If
End If

MsgBox "JavaScript files updated successfully!", vbInformation, "Fix JS Links"
