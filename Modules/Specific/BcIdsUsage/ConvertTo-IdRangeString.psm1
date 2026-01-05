function ConvertTo-IdRangeString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [int[]]$Ids
    )

    if (-not $Ids -or $Ids.Count -eq 0) { return '' }

    $sorted = @($Ids | Sort-Object -Unique)
    $ranges = New-Object System.Collections.Generic.List[string]

    $start = $sorted[0]
    $prev = $sorted[0]

    for ($i = 1; $i -lt $sorted.Count; $i++) {
        $current = $sorted[$i]
        if ($current -eq ($prev + 1)) {
            $prev = $current
            continue
        }

        if ($start -eq $prev) { $ranges.Add("$start") }
        else { $ranges.Add("$start-$prev") }

        $start = $current
        $prev = $current
    }

    if ($start -eq $prev) { $ranges.Add("$start") }
    else { $ranges.Add("$start-$prev") }

    return ($ranges -join ', ')
}