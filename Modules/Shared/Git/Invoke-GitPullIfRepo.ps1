function Invoke-GitPullIfRepo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepoPath
    )

    $gitDir = Join-Path -Path $RepoPath -ChildPath ".git"
    if (Test-Path -Path $gitDir -PathType Container) {
        Push-Location $RepoPath
        git pull
        Pop-Location
    }
}