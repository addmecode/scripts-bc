function Get-ObjectIdsFromAlFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AlFilePath
    )
    $SHARED_MODULES_PATH = Join-Path -Path $PSScriptRoot -ChildPath "../" -Resolve
    Import-Module -Name $(Join-Path -Path $SHARED_MODULES_PATH -ChildPath "BcFiles/Get-ObjectTypes.psm1" -Resolve) -Force
    $objectTypes = Get-ObjectTypes
    # Regex: matches object declarations at line start, skips // comment lines
    # Match examples:
    #   table 50100 "My Table"
    #   pageextension 50101 MyExt extends "Customer Card"
    #   permissionset 50102 "MY PERM"
    $objectDeclPattern = '(?im)^\s*(?!//)(?<type>' + ($objectTypes -join '|') + ')\s+(?<id>\d+)\b'

    $content = Get-Content -LiteralPath $AlFilePath -Raw -Encoding UTF8
    $matches = [regex]::Matches($content, $objectDeclPattern)
    $objects = foreach ($m in $matches) {
        $typeKey = $m.Groups['type'].Value.ToLowerInvariant()
        $idText = $m.Groups['id'].Value

        if (-not ($objectTypes -contains $typeKey)) { continue }

        [PSCustomObject]@{
            Type = (Get-Culture).TextInfo.ToTitleCase($typeKey)
            Id   = [int]$idText
        }
    }
    return $objects
}