function Get-UsedObjectIdsFromAlFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ProjectPath
    )
    $SHARED_MODULES_PATH = Join-Path -Path $PSScriptRoot -ChildPath "../../Shared" -Resolve
    Import-Module -Name $(Join-Path -Path $SHARED_MODULES_PATH -ChildPath "BcFiles/Get-ObjectTypes.psm1" -Resolve) -Force
    $objectTypes = Get-ObjectTypes

    # HashSet per object type
    $byType = @{}
    foreach ($t in ($objectTypes | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })) {
        $byType[$t] = [System.Collections.Generic.HashSet[int]]::new()
    }

    $alFiles = Get-ChildItem -LiteralPath $ProjectPath -Recurse -File -Filter '*.al' -ErrorAction Stop |
    Where-Object {
        # Skip
        $_.FullName -notmatch '\\(\.alpackages|\.git|\.vscode|node_modules|bin|obj)\\'
    }

    foreach ($file in $alFiles) {
        $fileObjects = Get-ObjectIdsFromAlFile -AlFilePath $file.FullName
        foreach ($obj in $fileObjects) {
            $null = $byType[$obj.Type].Add($obj.Id)
        }
    }
    # Return as sorted int[]
    $result = [ordered]@{}
    foreach ($t in ($objectTypes | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })) {
        $result[$t] = @($byType[$t] | Sort-Object)
    }
    return $result
}