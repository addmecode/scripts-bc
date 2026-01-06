Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$SHARED_MODULES_PATH = Join-Path -Path $PSScriptRoot -ChildPath "../../Modules/Shared" -Resolve
$SPECIFIC_MODULES_PATH = Join-Path -Path $PSScriptRoot -ChildPath "../../Modules/Specific" -Resolve
$PATH_SEPARATOR = [System.IO.Path]::PathSeparator
$env:PSModulePath = ($SHARED_MODULES_PATH, $SPECIFIC_MODULES_PATH, $env:PSModulePath) -join $PATH_SEPARATOR
Import-Module -Name File -Force
Import-Module -Name BcAppJson -Force
Import-Module -Name BcFiles -Force
Import-Module -Name BcIdsUsage -Force

$MY_ID_RANGES_FROM = 50100
$MY_ID_RANGES_TO = 50149
$ALL_MY_PROJECTS_DIR_PATH = 'C:\Users\adrri\Desktop\Projects\BC'
$OUTPUT_MARKDOWN_PATH = Join-Path -Path $ALL_MY_PROJECTS_DIR_PATH -ChildPath 'ids-usage-report.md'


$objectTypes = Get-ObjectTypes
if ($MY_ID_RANGES_FROM -gt $MY_ID_RANGES_TO) {
    throw "Invalid range: MyIdRangesFrom ($MY_ID_RANGES_FROM) > MyIdRangesTo ($MY_ID_RANGES_TO)."
}
if (-not (Test-Path -LiteralPath $ALL_MY_PROJECTS_DIR_PATH)) {
    throw "AllMyProjectsDirPath folder not found: $ALL_MY_PROJECTS_DIR_PATH"
}

$projectFolders = Get-ProjectFolders -RootPath $ALL_MY_PROJECTS_DIR_PATH 
if (-not $projectFolders -or $projectFolders.Count -eq 0) {
    throw "No AL projects found (missing app.json) in: $ALL_MY_PROJECTS_DIR_PATH"
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
[void]$sb.Append("- Projects folder: $ALL_MY_PROJECTS_DIR_PATH$nl")
[void]$sb.Append("- Free ID range: $MY_ID_RANGES_FROM-$MY_ID_RANGES_TO$nl$nl")

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
        if ($id -ge $MY_ID_RANGES_FROM -and $id -le $MY_ID_RANGES_TO) { $null = $usedInRange.Add($id) }
    }

    $freeRanges = Get-FreeIdsRangeString -From $MY_ID_RANGES_FROM -To $MY_ID_RANGES_TO -UsedIds $usedInRange
    $freeRanges
}
[void]$sb.Append('| ' + ($freeRowCells -join ' | ') + " |$nl")

# save
$md = $sb.ToString()
Write-Utf8NoBomFile -Path $OUTPUT_MARKDOWN_PATH -Content $md

Write-Output ([pscustomobject]@{
        OutputMarkdownPath = $OUTPUT_MARKDOWN_PATH
        ProjectsFound      = $projectFolders.Count
        GeneratedAt        = $now
    })
