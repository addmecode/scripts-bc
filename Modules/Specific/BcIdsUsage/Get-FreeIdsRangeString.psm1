function Get-FreeIdsRangeString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$From,

        [Parameter(Mandatory)]
        [int]$To,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.HashSet[int]]$UsedIds
    )
    if ($From -gt $To) { throw "From ($From) cannot be greater than To ($To)." }

    $ranges = New-Object System.Collections.Generic.List[string]
    $start = $null
    $prev = $null

    for ($i = $From; $i -le $To; $i++) {
        if (-not $UsedIds.Contains($i)) {
            if ($null -eq $start) {
                $start = $i
                $prev = $i
            }
            elseif ($i -eq ($prev + 1)) {
                $prev = $i
            }
            else {
                if ($start -eq $prev) { $ranges.Add("$start") } else { $ranges.Add("$start-$prev") }
                $start = $i
                $prev = $i
            }
        }
    }

    if ($null -ne $start) {
        if ($start -eq $prev) { $ranges.Add("$start") } else { $ranges.Add("$start-$prev") }
    }

    return ($ranges -join ', ')
}