$containerName = 'cnt-name'
$password = 'P@ssw0rd'
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object pscredential 'admin', $securePassword
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type 'Sandbox' -country 'us' -select 'Latest' -version "27"

New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -credential $credential `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -multitenant:$false `
    -assignPremiumPlan `
    -includeAL `
    -doNotExportObjectsToText `
    -updateHosts