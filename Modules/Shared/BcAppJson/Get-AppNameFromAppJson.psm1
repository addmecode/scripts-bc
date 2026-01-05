function Get-AppNameFromAppJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AppJsonPath
    )
    $raw = Get-Content -LiteralPath $AppJsonPath -Raw -Encoding UTF8
    $json = $raw | ConvertFrom-Json
    if ($null -ne $json.name -and -not [string]::IsNullOrWhiteSpace([string]$json.name)) {
        return [string]$json.name
    }
    else {
        throw "Failed to read Name in app.json ($AppJsonPath)"
    }
}