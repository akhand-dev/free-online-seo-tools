[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$toolsPath = Join-Path $projectRoot 'tools'
$toolMap = @{}
Get-ChildItem $toolsPath -Directory | ForEach-Object {
    $slug = $_.Name
    $htmlPath = Join-Path $_.FullName ($slug + '.html')
    if (Test-Path $htmlPath) {
        $toolMap[$slug] = "tools/$slug/$slug.html"
    }
}
$files = Get-ChildItem $projectRoot -Recurse -Include *.html -File | Where-Object { $_.DirectoryName -notmatch '\\(node_modules|\.git)$' }
$changed = 0
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $original = $content
    # Fix href and src attributes that reference a tool slug without path
    $content = $content -replace '(href|src)=(["''])([^"'':#\/]+)\2', {
        param($m)
        $attr = $m.Groups[1].Value
        $quote = $m.Groups[2].Value
        $val = $m.Groups[3].Value
        if ($toolMap.ContainsKey($val)) {
            "${attr}=${quote}$($toolMap[$val])${quote}"
        } else {
            $m.Value
        }
    }
    # Fix rel="canonical" href
    $content = $content -replace '(rel=["'']canonical["']\s+href=)(["''])([^"'']+)\2', {
        param($m)
        $prefix = $m.Groups[1].Value
        $quote = $m.Groups[2].Value
        $url = $m.Groups[3].Value
        if ($toolMap.ContainsKey($url)) {
            "${prefix}${quote}$($toolMap[$url])${quote}"
        } else {
            $m.Value
        }
    }
    # Fix property="og:url" content
    $content = $content -replace '(property=["'']og:url["']\s+content=)(["''])([^"'']+)\2', {
        param($m)
        $prefix = $m.Groups[1].Value
        $quote = $m.Groups[2].Value
        $url = $m.Groups[3].Value
        if ($toolMap.ContainsKey($url)) {
            "${prefix}${quote}$($toolMap[$url])${quote}"
        } else {
            $m.Value
        }
    }
    if ($content -ne $original) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $changed++
    }
}
[Windows.Forms.MessageBox]::Show("Link fix complete! $changed file(s) updated.", "Asegya Toolkit – Fix Links", 0, [Windows.Forms.MessageBoxIcon]::Information) | Out-Null
