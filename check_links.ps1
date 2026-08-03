# Check internal href links in HTML files and report any that point to non‑existent files
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$reportPath = Join-Path $projectRoot 'broken_links_report.txt'
$broken = @()
Get-ChildItem $projectRoot -Recurse -Include *.html -File | Where-Object { $_.DirectoryName -notmatch '\\(node_modules|\.git)$' } | ForEach-Object {
    $filePath = $_.FullName
    $lines = Get-Content $filePath
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $matches = [regex]::Matches($line, 'href="([^"#]+)"')
        foreach ($m in $matches) {
            $href = $m.Groups[1].Value.Trim()
            if ($href -match '^https?://') { continue }
            # Resolve relative path
            if ($href.StartsWith('/')) {
                $resolved = Join-Path $projectRoot ($href.TrimStart('/'))
            } else {
                $resolved = Join-Path $_.Directory.FullName $href
            }
            if (-not (Test-Path $resolved)) {
                $broken += "File: $filePath`nLine $($i+1): href='$href' resolves to missing '$resolved'`n"
            }
        }
    }
}
if ($broken.Count -eq 0) {
    Set-Content -Path $reportPath -Value 'No broken internal href links found.' -Encoding UTF8
} else {
    $report = $broken -join "`n"
    Set-Content -Path $reportPath -Value $report -Encoding UTF8
}
Write-Host "Link check complete. Report saved to $reportPath"
