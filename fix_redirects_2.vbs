Option Explicit

Dim fso, projectRoot
Set fso = CreateObject("Scripting.FileSystemObject")
projectRoot = fso.GetParentFolderName(WScript.ScriptFullName)

Dim changedXml, changedHtml
changedXml = 0
changedHtml = 0

' Setup Regex objects for XML
Dim regSitemapIndex1, regSitemapIndex2, regSitemapHtml
Set regSitemapIndex1 = CreateObject("VBScript.RegExp")
regSitemapIndex1.Global = True
regSitemapIndex1.Pattern = "/index\.html</loc>"

Set regSitemapIndex2 = CreateObject("VBScript.RegExp")
regSitemapIndex2.Global = True
regSitemapIndex2.Pattern = "index\.html</loc>"

Set regSitemapHtml = CreateObject("VBScript.RegExp")
regSitemapHtml.Global = True
regSitemapHtml.Pattern = "\.html</loc>"

' Setup Regex objects for JSON-LD in HTML
Dim regJsonIndexItem, regJsonIndexUrl, regJsonItem, regJsonUrl, regJsonId
Set regJsonIndexItem = CreateObject("VBScript.RegExp")
regJsonIndexItem.Global = True
regJsonIndexItem.Pattern = """item"":\s*""([^""]+)/index\.html"""

Set regJsonIndexUrl = CreateObject("VBScript.RegExp")
regJsonIndexUrl.Global = True
regJsonIndexUrl.Pattern = """url"":\s*""([^""]+)/index\.html"""

Set regJsonItem = CreateObject("VBScript.RegExp")
regJsonItem.Global = True
regJsonItem.Pattern = """item"":\s*""([^""]+)\.html"""

Set regJsonUrl = CreateObject("VBScript.RegExp")
regJsonUrl.Global = True
regJsonUrl.Pattern = """url"":\s*""([^""]+)\.html"""

Set regJsonId = CreateObject("VBScript.RegExp")
regJsonId.Global = True
regJsonId.Pattern = """@id"":\s*""([^""]+)\.html"""

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

' Processing XMLs
Sub ProcessXmls()
    Dim folderObj, file
    Set folderObj = fso.GetFolder(projectRoot)
    For Each file In folderObj.Files
        If LCase(fso.GetExtensionName(file.Name)) = "xml" Then
            UpdateXml file.Path
        End If
    Next
End Sub

Sub UpdateXml(filePath)
    Dim content, original
    content = ReadUTF8(filePath)
    original = content
    
    content = regSitemapIndex1.Replace(content, "/</loc>")
    content = regSitemapIndex2.Replace(content, "</loc>")
    content = regSitemapHtml.Replace(content, "</loc>")
    
    If content <> original Then
        WriteUTF8 filePath, content
        changedXml = changedXml + 1
    End If
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
    Dim content, original
    content = ReadUTF8(filePath)
    original = content
    
    content = regJsonIndexItem.Replace(content, """item"": ""$1/""")
    content = regJsonIndexUrl.Replace(content, """url"": ""$1/""")
    
    content = regJsonItem.Replace(content, """item"": ""$1""")
    content = regJsonUrl.Replace(content, """url"": ""$1""")
    content = regJsonId.Replace(content, """@id"": ""$1""")
    
    If content <> original Then
        WriteUTF8 filePath, content
        changedHtml = changedHtml + 1
    End If
End Sub

' Main Execution
ProcessXmls
ProcessFolder projectRoot

MsgBox "Part 2 link fix complete! " & changedHtml & " HTML file(s) and " & changedXml & " XML file(s) updated.", vbInformation, "Asegya Toolkit - Fix Redirects Part 2"
