Option Explicit

Dim objFSO, projectRoot, toolsDir
Set objFSO = CreateObject("Scripting.FileSystemObject")
projectRoot = "C:\Users\acl1\Documents\as2152\free-online-seo-tools"
toolsDir = projectRoot & "\tools"

If Not objFSO.FolderExists(toolsDir) Then
    objFSO.CreateFolder(toolsDir)
End If

' Keep track of the tools we are moving from root so we can update their links everywhere
Dim movedTools
Set movedTools = CreateObject("Scripting.Dictionary")

' Define standard pages that should NEVER be moved
Dim skipFiles
Set skipFiles = CreateObject("Scripting.Dictionary")
skipFiles.Add "index.html", True
skipFiles.Add "about.html", True
skipFiles.Add "contact.html", True
skipFiles.Add "privacy-policy.html", True
skipFiles.Add "terms-of-service.html", True
skipFiles.Add "404.html", True

' --- Step 1: Move Root Tool HTML files into tools/ subfolders ---
Dim rootFolder, file, baseName, newDir, newFilePath
Set rootFolder = objFSO.GetFolder(projectRoot)

For Each file In rootFolder.Files
    If LCase(objFSO.GetExtensionName(file.Name)) = "html" Then
        ' Skip the main pages
        If Not skipFiles.Exists(LCase(file.Name)) Then
            baseName = objFSO.GetBaseName(file.Name)
            newDir = toolsDir & "\" & baseName
            
            ' Create folder if it doesn't exist
            If Not objFSO.FolderExists(newDir) Then
                objFSO.CreateFolder(newDir)
            End If
            
            ' Move file to the new folder
            newFilePath = newDir & "\" & file.Name
            If objFSO.FileExists(newFilePath) Then
                objFSO.DeleteFile(newFilePath)
            End If
            objFSO.MoveFile file.Path, newFilePath
            
            ' Record that we moved this tool
            movedTools.Add baseName, True
        End If
    End If
Next

' --- Step 2: Update Links & Sitemaps ---
Dim regEx
Set regEx = New RegExp
regEx.Global = True
regEx.IgnoreCase = True

' Helper to read UTF-8 files safely
Function ReadUTF8(filePath)
    Dim objStream
    Set objStream = CreateObject("ADODB.Stream")
    objStream.CharSet = "utf-8"
    objStream.Open
    objStream.LoadFromFile(filePath)
    ReadUTF8 = objStream.ReadText()
    objStream.Close
End Function

' Helper to write UTF-8 files safely
Sub WriteUTF8(filePath, content)
    Dim objStream
    Set objStream = CreateObject("ADODB.Stream")
    objStream.CharSet = "utf-8"
    objStream.Open
    objStream.WriteText content
    objStream.SaveToFile filePath, 2 ' 2 = adSaveCreateOverWrite
    objStream.Close
End Sub

' --- Update Sitemap & Pagelist XML ---
Sub UpdateXML(xmlPath)
    If objFSO.FileExists(xmlPath) Then
        On Error Resume Next
        Dim xmlContent, newXmlContent, key
        xmlContent = ReadUTF8(xmlPath)
        If Err.Number = 0 Then
            newXmlContent = xmlContent
            
            ' Update tools already in tools folder
            regEx.Pattern = "https://free-online-seo-tools\.vercel\.app/tools/([^</]+)\.html"
            newXmlContent = regEx.Replace(newXmlContent, "https://free-online-seo-tools.vercel.app/tools/$1/$1.html")
            
            ' Update tools just moved from root
            For Each key In movedTools.Keys
                newXmlContent = Replace(newXmlContent, "https://free-online-seo-tools.vercel.app/" & key & ".html", "https://free-online-seo-tools.vercel.app/tools/" & key & "/" & key & ".html")
            Next
            
            If xmlContent <> newXmlContent Then
                WriteUTF8 xmlPath, newXmlContent
            End If
        End If
        On Error GoTo 0
    End If
End Sub

UpdateXML(projectRoot & "\sitemap.xml")
UpdateXML(projectRoot & "\pagelist.xml")

' --- Update internal links in all HTML files recursively ---
Sub ProcessFolder(fldrPath)
    Dim fldr, f, subFldr, fContent, fNewContent, key
    Set fldr = objFSO.GetFolder(fldrPath)
    
    For Each f In fldr.Files
        If LCase(objFSO.GetExtensionName(f.Name)) = "html" Then
            On Error Resume Next
            fContent = ReadUTF8(f.Path)
            If Err.Number = 0 Then
                fNewContent = fContent
                
                ' Fix tools/name.html links
                regEx.Pattern = "href=""([^""]*?)tools/([^""/]+)\.html"""
                fNewContent = regEx.Replace(fNewContent, "href=""$1tools/$2/$2.html""")
                
                regEx.Pattern = "src=""([^""]*?)tools/([^""/]+)\.html"""
                fNewContent = regEx.Replace(fNewContent, "src=""$1tools/$2/$2.html""")
                
                ' Fix root level links that were moved
                For Each key In movedTools.Keys
                    fNewContent = Replace(fNewContent, "href=""" & key & ".html""", "href=""tools/" & key & "/" & key & ".html""")
                    fNewContent = Replace(fNewContent, "href=""/" & key & ".html""", "href=""/tools/" & key & "/" & key & ".html""")
                Next
                
                If fContent <> fNewContent Then
                    WriteUTF8 f.Path, fNewContent
                End If
            End If
            On Error GoTo 0
        End If
    Next
    
    For Each subFldr In fldr.SubFolders
        ProcessFolder(subFldr.Path)
    Next
End Sub

ProcessFolder(projectRoot)

MsgBox "All remaining root tools were moved successfully, and your sitemap and internal links have been updated!", 64, "Process Complete"
