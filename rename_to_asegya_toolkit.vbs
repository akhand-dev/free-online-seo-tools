Option Explicit

Dim objFSO, projectRoot
Set objFSO = CreateObject("Scripting.FileSystemObject")

projectRoot = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Replacements — longer strings first to avoid partial matches
Dim replacements(5, 1)
replacements(0, 0) = "Asegya ToolNest"  : replacements(0, 1) = "Asegya Toolkit"
replacements(1, 0) = "ToolNest's"       : replacements(1, 1) = "Asegya Toolkit's"
replacements(2, 0) = "ToolNest"          : replacements(2, 1) = "Asegya Toolkit"
replacements(3, 0) = "RankifyTools"      : replacements(3, 1) = "Asegya Toolkit"
replacements(4, 0) = "rankifytools"      : replacements(4, 1) = "Asegya Toolkit"
replacements(5, 0) = "Rankifytools"      : replacements(5, 1) = "Asegya Toolkit"

Dim validExts
Set validExts = CreateObject("Scripting.Dictionary")
validExts.Add "html", True
validExts.Add "json", True
validExts.Add "md",   True
validExts.Add "js",   True
validExts.Add "xml",  True
validExts.Add "txt",  True

Dim filesChanged
filesChanged = 0

Function ReadUTF8(filePath)
    Dim s
    Set s = CreateObject("ADODB.Stream")
    s.CharSet = "utf-8"
    s.Open
    s.LoadFromFile filePath
    ReadUTF8 = s.ReadText()
    s.Close
    Set s = Nothing
End Function

Sub WriteUTF8(filePath, content)
    Dim s
    Set s = CreateObject("ADODB.Stream")
    s.CharSet = "utf-8"
    s.Open
    s.WriteText content
    s.SaveToFile filePath, 2
    s.Close
    Set s = Nothing
End Sub

Sub ProcessFolder(folderPath)
    Dim folder, file, subFolder, ext, original, updated, i

    Set folder = objFSO.GetFolder(folderPath)
    If LCase(folder.Name) = ".git" Or LCase(folder.Name) = "node_modules" Then Exit Sub

    For Each file In folder.Files
        ext = LCase(objFSO.GetExtensionName(file.Name))
        If validExts.Exists(ext) Then
            On Error Resume Next
            original = ReadUTF8(file.Path)
            If Err.Number = 0 Then
                updated = original
                For i = 0 To UBound(replacements, 1)
                    updated = Replace(updated, replacements(i, 0), replacements(i, 1))
                Next
                If updated <> original Then
                    WriteUTF8 file.Path, updated
                    filesChanged = filesChanged + 1
                End If
            End If
            On Error GoTo 0
        End If
    Next

    For Each subFolder In folder.SubFolders
        ProcessFolder subFolder.Path
    Next
End Sub

ProcessFolder projectRoot

MsgBox "Done — " & filesChanged & " files renamed to Asegya Toolkit.", 64, "Asegya Toolkit"
