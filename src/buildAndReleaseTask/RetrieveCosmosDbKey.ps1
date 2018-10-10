[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$resourceGroupName = Get-VstsInput -Name "ResourceGroupName" -Require
$cosmosDbAccountName = Get-VstsInput -Name "cosmosDbAccountName" -Require
$connectedServiceNameARM = Get-VstsInput -Name "ConnectedServiceNameARM" -Require
$outputVariableName = Get-VstsInput -Name "OutputVariableName" -Default "CosmosKey"
$keyType = Get-VstsInput -Name "KeyType" -Default "PrimaryMasterKey"

$endPointRM = Get-VstsEndpoint -Name $connectedServiceNameARM -Require
$subscriptionId = $endpointRM.Data.subscriptionId

$clientId = $endPointRM.Auth.Parameters.ServicePrincipalId
$clientSecret = $endPointRM.Auth.Parameters.ServicePrincipalKey
$tenantId = $endPointRM.Auth.Parameters.TenantId

$adTokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$resource = "https://management.azure.com/"

$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    resource      = $resource
}

$response = Invoke-RestMethod -Method 'Post' -Uri $adTokenUrl -ContentType "application/x-www-form-urlencoded" -Body $body

$ARMToken = $response.access_token

$keys = Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DocumentDb/databaseAccounts/$cosmosDbAccountName/listKeys/?api-version=2016-03-31" -Method POST -Headers @{Authorization="Bearer $ARMToken"}

switch ($keyType) {
    "PrimaryMasterKey"              { $keyValue = $keys.primaryMasterKey }
    "SecondaryMasterKey"            { $keyValue = $keys.secondaryMasterKey }
    "PrimaryReadonlyMasterKey"      { $keyValue = $keys.primaryReadonlyMasterKey }
    "SecondaryReadonlyMasterKey"    { $keyValue = $keys.secondaryReadonlyMasterKey }
}

Write-Host "##vso[task.setvariable variable=$outputVariableName;issecret=true]$keyValue"