Option Explicit

' ============================================================
'  fix_links.vbs
'  Scans all HTML files and fixes broken internal links by
'  adding the proper "tools/<slug>/<slug>.html" prefix.
'  Also updates canonical and og:url meta tags to the correct URLs.
' ============================================================

Dim fso, projectRoot, toolsFolder, htmlFiles, file
Set fso = CreateObject("Scripting.FileSystemObject")
projectRoot = fso.GetParentFolderName(WScript.ScriptFullName)
toolsFolder = fso.BuildPath(projectRoot, "tools")

' Build a dictionary of known tool slugs to their HTML paths
Dim toolMap
Set toolMap = CreateObject("Scripting.Dictionary")
Dim toolSub, toolHtml, slug
If fso.FolderExists(toolsFolder) Then
    For Each toolSub In fso.GetFolder(toolsFolder).SubFolders
        slug = fso.GetFileName(toolSub.Path)
        ' Assume the main HTML file is <slug>.html inside the subfolder
        toolHtml = fso.BuildPath(toolSub.Path, slug & ".html")
        If fso.FileExists(toolHtml) Then
            toolMap.Add slug, "tools/" & slug & "/" & slug & ".html"
        End If
    Next
End If

' Recursively collect all .html files in the project (including index.html)
Dim filesToProcess
Set filesToProcess = CreateObject("System.Collections.ArrayList")
CollectHtmlFiles projectRoot, filesToProcess

Dim totalChanged, fileChanged
totalChanged = 0

Dim content, newContent
For Each file In filesToProcess
    content = ReadUTF8(file.Path)
    newContent = FixLinks(content, toolMap)
    If newContent <> content Then
        WriteUTF8 file.Path, newContent
        totalChanged = totalChanged + 1
    End If
Next

MsgBox "Link fix complete! " & totalChanged & " file(s) updated.", 64, "Asegya Toolkit – Fix Links"

' ======================== Helper Functions ========================

Sub CollectHtmlFiles(folderPath, list)
    Dim folder, subFolder, f
    Set folder = fso.GetFolder(folderPath)
    For Each f In folder.Files
        If LCase(fso.GetExtensionName(f.Name)) = "html" Then
            list.Add f
        End If
    Next
    For Each subFolder In folder.SubFolders
        ' Skip node_modules and .git
        If LCase(subFolder.Name) <> "node_modules" And LCase(subFolder.Name) <> ".git" Then
            CollectHtmlFiles subFolder.Path, list
        End If
    Next
End Sub

Function ReadUTF8(filePath)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.CharSet = "utf-8"
    stream.Open
    stream.LoadFromFile filePath
    ReadUTF8 = stream.ReadText()
    stream.Close
End Function

Sub WriteUTF8(filePath, txt)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.CharSet = "utf-8"
    stream.Open
    stream.WriteText txt
    stream.SaveToFile filePath, 2 ' adSaveCreateOverWrite
    stream.Close
End Sub

Function FixLinks(html, map)
    Dim reHref, reMeta, matches, m, hrefVal, newHref, changed
    changed = False
    Set reHref = New RegExp
    reHref.Global = True
    reHref.IgnoreCase = True
    reHref.Pattern = "href=\"([^\"]*)\""
    Set matches = reHref.Execute(html)
    Dim i
    For i = matches.Count - 1 To 0 Step -1
        Set m = matches(i)
        hrefVal = m.SubMatches(0)
        ' Skip external URLs, anchors, absolute paths, or already correct paths
        If Not (Left(hrefVal, 4) = "http" Or Left(hrefVal, 1) = "#" Or Left(hrefVal, 1) = "/" Or Left(hrefVal, 6) = "tools/" ) Then
            If map.Exists(hrefVal) Then
                newHref = map(hrefVal)
                html = Left(html, m.FirstIndex) & "href=\"" & newHref & "\"" & Mid(html, m.FirstIndex + m.Length + 1)
                changed = True
            End If
        End If
    Next

    ' Fix canonical and og:url meta tags (content attribute)
    Set reMeta = New RegExp
    reMeta.Global = True
    reMeta.IgnoreCase = True
    reMeta.Pattern = "(rel=\"canonical\"|property=\"og:url\")\s+href=\"([^\"]*)\"|content=\"([^\"]*)\""
    Set matches = reMeta.Execute(html)
    For i = matches.Count - 1 To 0 Step -1
        Set m = matches(i)
        Dim attrVal
        If m.SubMatches(1) <> "" Then
            attrVal = m.SubMatches(1) ' href value for canonical
        ElseIf m.SubMatches(2) <> "" Then
            attrVal = m.SubMatches(2) ' content value for og:url
        Else
            attrVal = ""
        End If
        If attrVal <> "" Then
            If Not (Left(attrVal, 4) = "http" Or Left(attrVal, 1) = "/") Then
                If map.Exists(attrVal) Then
                    Dim newVal
                    newVal = map(attrVal)
                    html = Left(html, m.FirstIndex) & Replace(m.Value, attrVal, newVal) & Mid(html, m.FirstIndex + m.Length + 1)
                    changed = True
                End If
            End If
        End If
    Next

    FixLinks = html
End Function
