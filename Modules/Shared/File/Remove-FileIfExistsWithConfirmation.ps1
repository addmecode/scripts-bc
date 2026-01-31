function Remove-FileIfExistsWithConfirmation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FilePathToRemove
    )
    if (-not (Test-Path -Path $FilePathToRemove -PathType Leaf)) {
        return
    }

    $CONFIRM_MSG = "File already exists at $FilePathToRemove. Remove it? (y/N)"
    $CANCEL_MSG = "Operation cancelled because $FilePathToRemove already exists"
    $confirmation = Read-Host $CONFIRM_MSG
    if ($confirmation -match '^(y|yes)$') {
        Remove-Item -LiteralPath $FilePathToRemove -Force
        return
    }
    throw $CANCEL_MSG
}
