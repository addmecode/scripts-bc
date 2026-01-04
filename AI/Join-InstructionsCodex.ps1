$codexHome = Join-Path $HOME ".codex"
$rulesDir = "C:\Users\adrri\Desktop\Projects\bc-public-repos\alguidelines\content\docs\agentic-coding\vibe-coding-rules"
$outFile = Join-Path $codexHome "AGENTS.md"

$excludeNames = @(
    "README.md",
    "_index.md"
)
if (-not (Test-Path $rulesDir)) {
    throw "rulesDir not found: $rulesDir"
}

@"
# Global Rules (Codex)

## Scope guard (IMPORTANT)
Apply the **AL RULES** section ONLY when this repository is a Microsoft Dynamics 365 Business Central AL project.

Treat this repo as an AL project if ANY of the following is true:
- A file named app.json exists (commonly at the extension root), OR
- The repo contains one or more *.al files, OR
- .vscode/launch.json contains a configuration with "type": "al".

If NONE of the conditions are true:
- IGNORE the entire **AL RULES** section below
- behave normally without these AL-specific rules.

---

# AL RULES
"@ | Set-Content $outFile

$files = Get-ChildItem -Path $rulesDir -File -Filter "*.md" | Where-Object {
    if ($excludeNames -contains $($_.Name)) { return $false }
    return $true
} | Sort-Object Name

if ($files.Count -eq 0) {
    Write-Warning "No files to merge in: $rulesDir"
    exit 0
}

foreach ($f in $files) {
    "`n---`n# Source: $($f.Name)`n---`n" | Add-Content $outFile
    Get-Content -Path $f.FullName | Add-Content $outFile
}

Write-Host "OK: Merged $($files.Count) file(s) into $outFile"
