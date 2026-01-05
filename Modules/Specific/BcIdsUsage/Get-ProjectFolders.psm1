function Get-ProjectFolders {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RootPath
    )
    if (-not (Test-Path -LiteralPath $RootPath)) {
        throw "Folder not found: $RootPath"
    }
    $dirs = Get-ChildItem -LiteralPath $RootPath -Directory -Recurse -ErrorAction Stop
    $projects = foreach ($d in $dirs) {
        $appJsonPath = Join-Path -Path $d.FullName -ChildPath 'app.json'
        if (Test-Path -LiteralPath $appJsonPath) { $d }
    }
    return $projects
}