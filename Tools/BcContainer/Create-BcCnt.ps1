$CONTAINER_NAME = "cnt-name"
$SECURE_PASSWORD = ConvertTo-SecureString -String $PASSWORD -AsPlainText -Force
$CREDENTIAL = New-Object pscredential 'admin', $SECURE_PASSWORD
$PASSWORD = 'P@ssw0rd'
$ARTIFACT_URL = Get-BcArtifactUrl -type 'Sandbox' -country 'us' -select 'Latest' -version "27"
$SET_DNS = $true


$PARAMETERS = @{
    accept_eula              = $true
    containerName            = $CONTAINER_NAME
    credential               = $CREDENTIAL
    auth                     = 'UserPassword'
    artifactUrl              = $ARTIFACT_URL
    multitenant              = $false
    assignPremiumPlan        = $true
    includeAL                = $true
    doNotExportObjectsToText = $true
    updateHosts              = $true
}

if ($SET_DNS) { $PARAMETERS.dns = "8.8.8.8" }

New-BcContainer @PARAMETERS
