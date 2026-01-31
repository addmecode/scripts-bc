#* Run this as admin
$GLOBAL_SETTINGS_PATH = "path-to-global-settings\settings.json"
$NEW_SETTINGS_PATH = "path-to-settings-in-al-project\settings.json"


Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SHARED_MODULES_PATH = Join-Path -Path $PSScriptRoot -ChildPath "../../Modules/Shared" -Resolve
$PATH_SEPARATOR = [System.IO.Path]::PathSeparator
$env:PSModulePath = ($SHARED_MODULES_PATH, $env:PSModulePath) -join $PATH_SEPARATOR
Import-Module -Name Git -Force
Import-Module -Name File -Force


if (-not (Test-Path -Path $GLOBAL_SETTINGS_PATH -PathType Leaf)) {
    throw "Global settings.json path does not exist: $GLOBAL_SETTINGS_PATH"
}
$globalSettingsDir = Resolve-Path -Path $(Split-Path -Parent $GLOBAL_SETTINGS_PATH)
Invoke-GitPullIfRepo -RepoPath $globalSettingsDir -ErrorAction Stop
Remove-FileIfExistsWithConfirmation -FilePathToRemove $NEW_SETTINGS_PATH -ErrorAction Stop
New-Item -ItemType SymbolicLink -Path $NEW_SETTINGS_PATH -Target $GLOBAL_SETTINGS_PATH -ErrorAction Stop
