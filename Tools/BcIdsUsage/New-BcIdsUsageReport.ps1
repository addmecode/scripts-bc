Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$SHARED_MODULES_PATH = Join-Path -Path $PSScriptRoot -ChildPath "../../Modules/Shared" -Resolve
$BCIDSUSAGE_MODULES_PATH = Join-Path -Path $PSScriptRoot -ChildPath "../../Modules/Specific/BcIdsUsage" -Resolve
Import-Module -Name $(Join-Path -Path $SHARED_MODULES_PATH -ChildPath "File/Write-Utf8NoBomFile.psm1" -Resolve) -Force
Import-Module -Name $(Join-Path -Path $SHARED_MODULES_PATH -ChildPath "BcAppJson/Get-AppNameFromAppJson.psm1" -Resolve) -Force
Import-Module -Name $(Join-Path -Path $SHARED_MODULES_PATH -ChildPath "BcFiles/Get-ObjectIdsFromAlFile.psm1" -Resolve) -Force
Import-Module -Name $(Join-Path -Path $SHARED_MODULES_PATH -ChildPath "BcFiles/Get-ObjectTypes.psm1" -Resolve) -Force
Import-Module -Name $(Join-Path -Path $BCIDSUSAGE_MODULES_PATH -ChildPath "ConvertTo-IdRangeString.psm1" -Resolve) -Force
Import-Module -Name $(Join-Path -Path $BCIDSUSAGE_MODULES_PATH -ChildPath "Get-FreeIdsRangeString.psm1" -Resolve) -Force
Import-Module -Name $(Join-Path -Path $BCIDSUSAGE_MODULES_PATH -ChildPath "Get-ProjectFolders.psm1" -Resolve) -Force
Import-Module -Name $(Join-Path -Path $BCIDSUSAGE_MODULES_PATH -ChildPath "Get-UsedObjectIdsFromAlFiles.psm1" -Resolve) -Force

$MyIdRangesFrom = 50100
$MyIdRangesTo = 50149
$AllMyProjectsDirPath = 'C:\Users\adrri\Desktop\Projects\BC'
$OutputMarkdownPath = Join-Path -Path $AllMyProjectsDirPath -ChildPath 'ids-usage-report.md'


$objectTypes = Get-ObjectTypes
if ($MyIdRangesFrom -gt $MyIdRangesTo) {
    throw "Invalid range: MyIdRangesFrom ($MyIdRangesFrom) > MyIdRangesTo ($MyIdRangesTo)."
}
if (-not (Test-Path -LiteralPath $AllMyProjectsDirPath)) {
    throw "AllMyProjectsDirPath folder not found: $AllMyProjectsDirPath"
}

$projectFolders = Get-ProjectFolders -RootPath $AllMyProjectsDirPath 
if (-not $projectFolders -or $projectFolders.Count -eq 0) {
    throw "No AL projects found (missing app.json) in: $AllMyProjectsDirPath"
}

$perExtension = New-Object System.Collections.Generic.List[pscustomobject]
$globalUsed = @{}
foreach ($t in ($objectTypes | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })) {
    $globalUsed[$t] = [System.Collections.Generic.HashSet[int]]::new()
}

foreach ($proj in $projectFolders) {
    $appJsonPath = Join-Path -Path $proj.FullName -ChildPath 'app.json'
    $extName = Get-AppNameFromAppJson -AppJsonPath $appJsonPath

    $usedByType = Get-UsedObjectIdsFromAlFiles -ProjectPath $proj.FullName
    # populate globalUsed
    foreach ($t in ($objectTypes | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })) {
        foreach ($id in $usedByType[$t]) {
            $null = $globalUsed[$t].Add([int]$id)
        }
    }

    # build row for table 1
    $row = [ordered]@{
        'extension name' = $extName
    }
    foreach ($t in ($objectTypes | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })) {
        $colName = ($t.ToLowerInvariant()) # e.g. "report"
        $row[$colName] = ConvertTo-IdRangeString -Ids $usedByType[$t]
    }

    $perExtension.Add([pscustomobject]$row) | Out-Null
}

$nl = "`r`n"
$now = Get-Date

$allColumns = @('extension name') + $objectTypes

$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("# AL - Used and Free Object IDs$nl$nl")
[void]$sb.Append("- Generated at: $($now.ToString('yyyy-MM-dd HH:mm:ss'))$nl")
[void]$sb.Append("- Projects folder: $AllMyProjectsDirPath$nl")
[void]$sb.Append("- Free ID range: $MyIdRangesFrom-$MyIdRangesTo$nl$nl")

# Table 1: used
[void]$sb.Append("## Used IDs per extension$nl$nl")

# header
[void]$sb.Append('| ' + ($allColumns -join ' | ') + " |$nl")
[void]$sb.Append('| ' + (($allColumns | ForEach-Object { '---' }) -join ' | ') + " |$nl")

foreach ($row in ($perExtension | Sort-Object 'extension name')) {
    $cells = foreach ($c in $allColumns) {
        $v = $row.$c
        if ([string]::IsNullOrWhiteSpace($v)) { '' } else { ($v -replace '\|', '\|') }
    }
    [void]$sb.Append('| ' + ($cells -join ' | ') + " |$nl")
}

# Table 2: free
[void]$sb.Append("$nl## Free IDs in the selected range$nl$nl")

$freeColumns = $objectTypes

[void]$sb.Append('| ' + ($freeColumns -join ' | ') + " |$nl")
[void]$sb.Append('| ' + (($freeColumns | ForEach-Object { '---' }) -join ' | ') + " |$nl")

$freeRowCells = foreach ($t in ($objectTypes | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })) {
    # take only used within the range
    $usedInRange = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($id in $globalUsed[$t]) {
        if ($id -ge $MyIdRangesFrom -and $id -le $MyIdRangesTo) { $null = $usedInRange.Add($id) }
    }

    $freeRanges = Get-FreeIdsRangeString -From $MyIdRangesFrom -To $MyIdRangesTo -UsedIds $usedInRange
    $freeRanges
}
[void]$sb.Append('| ' + ($freeRowCells -join ' | ') + " |$nl")

# save
$md = $sb.ToString()
Write-Utf8NoBomFile -Path $OutputMarkdownPath -Content $md

Write-Output ([pscustomobject]@{
        OutputMarkdownPath = $OutputMarkdownPath
        ProjectsFound      = $projectFolders.Count
        GeneratedAt        = $now
    })
