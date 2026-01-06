$CODEX_HOME = Join-Path $HOME ".codex"
$RULES_DIR = "C:\Users\adrri\Desktop\Projects\bc-public-repos\alguidelines\content\docs\agentic-coding\vibe-coding-rules"
$OUT_FILE = Join-Path $CODEX_HOME "AGENTS.md"

$EXCLUDE_NAMES = @(
    "README.md",
    "_index.md"
)
if (-not (Test-Path $RULES_DIR)) {
    throw "rulesDir not found: $RULES_DIR"
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
"@ | Set-Content $OUT_FILE

$FILES = Get-ChildItem -Path $RULES_DIR -File -Filter "*.md" | Where-Object {
    if ($EXCLUDE_NAMES -contains $($_.Name)) { return $false }
    return $true
} | Sort-Object Name

if ($FILES.Count -eq 0) {
    Write-Warning "No files to merge in: $RULES_DIR"
    exit 0
}

foreach ($f in $FILES) {
    "`n---`n# Source: $($f.Name)`n---`n" | Add-Content $OUT_FILE
    Get-Content -Path $f.FullName | Add-Content $OUT_FILE
}

Write-Host "OK: Merged $($FILES.Count) file(s) into $OUT_FILE"
