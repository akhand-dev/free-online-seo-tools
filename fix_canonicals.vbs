Option Explicit

Dim fso, projectRoot
Set fso = CreateObject("Scripting.FileSystemObject")
projectRoot = fso.GetParentFolderName(WScript.ScriptFullName)

Dim changedHtml
changedHtml = 0

' Setup Regex to find canonical tags
Dim regCanonical
Set regCanonical = CreateObject("VBScript.RegExp")
regCanonical.Global = True
regCanonical.IgnoreCase = True
regCanonical.Pattern = "<link\s+rel=""canonical""[^>]*>"

' Helper functions for UTF-8 read/write
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
    stream.SaveToFile filePath, 2 ' adSaveCreateOverWrite
    stream.Close
End Sub

' Processing HTML folders
Sub ProcessFolder(folderPath)
    Dim folderObj, subFolder, file
    Set folderObj = fso.GetFolder(folderPath)
    
    For Each file In folderObj.Files
        If LCase(fso.GetExtensionName(file.Name)) = "html" Then
            UpdateHtml file.Path
        End If
    Next
    
    For Each subFolder In folderObj.SubFolders
        If LCase(subFolder.Name) <> "node_modules" And LCase(subFolder.Name) <> ".git" Then
            ProcessFolder subFolder.Path
        End If
    Next
End Sub

Sub UpdateHtml(filePath)
    Dim content, original, matches, i, matchStr, firstMatch
    content = ReadUTF8(filePath)
    original = content
    
    Set matches = regCanonical.Execute(content)
    
    If matches.Count > 1 Then
        ' We have duplicate canonical tags! Keep the first, remove the rest.
        firstMatch = matches.Item(0).Value
        
        ' Temporarily replace the first one with a placeholder so we don't delete it
        content = Replace(content, firstMatch, "___TEMP_CANONICAL_PLACEHOLDER___", 1, 1)
        
        ' Remove all remaining canonical tags
        content = regCanonical.Replace(content, "")
        
        ' Restore the first canonical tag
        content = Replace(content, "___TEMP_CANONICAL_PLACEHOLDER___", firstMatch)
    End If
    
    If content <> original Then
        WriteUTF8 filePath, content
        changedHtml = changedHtml + 1
    End If
End Sub

' Main Execution
ProcessFolder projectRoot

MsgBox "Duplicate Canonical fix complete! " & changedHtml & " HTML file(s) updated.", vbInformation, "Asegya Toolkit - Fix Canonicals"
