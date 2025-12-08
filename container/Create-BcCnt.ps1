$containerName = "cnt-name"
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object pscredential 'admin', $securePassword
$password = 'P@ssw0rd'
$artifactUrl = Get-BcArtifactUrl -type 'Sandbox' -country 'us' -select 'Latest' -version "27"
$setDns = $true


$parameters = @{
    accept_eula              = $true
    containerName            = $containerName
    credential               = $credential
    auth                     = 'UserPassword'
    artifactUrl              = $artifactUrl
    multitenant              = $false
    assignPremiumPlan        = $true
    includeAL                = $true
    doNotExportObjectsToText = $true
    updateHosts              = $true
}

if ($setDns) { $parameters.dns = "8.8.8.8" }

New-BcContainer @parameters