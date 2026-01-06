@{
    RootModule = 'BcIdsUsage.psm1'
    ModuleVersion = '1.0.0'
    GUID = '729067de-1cae-4606-9f1a-0f4215925ba3'
    RequiredModules = @('BcFiles')
    FunctionsToExport = @('ConvertTo-IdRangeString', 'Get-FreeIdsRangeString', 'Get-ProjectFolders', 'Get-UsedObjectIdsFromAlFiles')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}
