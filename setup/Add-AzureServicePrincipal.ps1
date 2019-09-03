param(
    [parameter(mandatory = $true)]
    [string]$SubscriptionId,
    [string]$ServicePrincipalName = "TerraformSample"
)
$ErrorActionPreference = "Stop"

function Find-ServicePrincipal {
    param(
        [parameter(mandatory = $true)]
        [string]$ServicePrincipalName
    )
    Write-Host "Find ServicePrincipal by displayName[$ServicePrincipalName]" -ForegroundColor Green
    $servicePrincipalJson = az ad sp list --all --query "[?displayName=='$ServicePrincipalName']"
    $servicePrincipal = $servicePrincipalJson | ConvertFrom-Json
    if ($servicePrincipal) {
        Write-Host "ServicePrincipal found" -ForegroundColor Green
    }
    else {
        Write-Host "ServicePrincipal NOT found" -ForegroundColor Green
    }
    Write-Host $servicePrincipalJson
    return $servicePrincipal
}

function Add-ServicePrincipal {
    param(
        [string]$Role = "Contributor",
        [parameter(mandatory = $true)]
        [string]$SubscriptionId,
        [parameter(mandatory = $true)]
        [string]$ServicePrincipalName
    )
    $scope = "/subscriptions/$SubscriptionId"
    Write-Host "Add new ServicePrincipal[Name=$ServicePrincipalName, Role=$Role, Scope=$scope]" -ForegroundColor Green
    Confirm-ExecuteProcess
    $newServicePrincipalJson = az ad sp create-for-rbac --name $ServicePrincipalName --role="$Role" --scopes="$scope"
    $newServicePrincipal = $newServicePrincipalJson | ConvertFrom-Json
    Write-Host "Successfully registered new ServicePrincipal" -ForegroundColor Green
    Write-Host $newServicePrincipalJson
    return $newServicePrincipal
}

function Save-DefaultTfvars {
    param(
        [string]$Tfvars = "azure_sp.tfvars",
        [parameter(mandatory = $true)]
        $NewServicePrincipal,
        [parameter(mandatory = $true)]
        [string]$SubscriptionId
    )
    Write-Host "Save ServicePrincipal informations to tfvars file[$Tfvars]" -ForegroundColor Green
    Confirm-ExecuteProcess
    $clientId = $NewServicePrincipal.appId
    $clientSecret = $NewServicePrincipal.password
    $tenantId = $NewServicePrincipal.tenant
    $content = "client_id = `"${clientId}`"`n"
    $content += "client_secret = `"${clientSecret}`"`n"
    $content += "tenant_id = `"${tenantId}`"`n"
    $content += "subscription_id = `"${SubscriptionId}`"`n"
    Set-Content -Path $tfvars -Value $content
    Write-Host "Successfully saved to file" -ForegroundColor Green
}

function Confirm-ExecuteProcess {
    $input = Read-Host "Do you want to execute the process? ( [Y]es / [N]o )"
    Switch ($input) {
        { $_ -eq "Y" -or $_ -eq "YES" } { 
            #execute process
        }
        default {
            throw "Processing was interrupted"
        }
    }
}

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
Push-Location $scriptDir

try {
    az login
    az account set --subscription $SubscriptionId

    $servicePrincipal = Find-ServicePrincipal -ServicePrincipalName $ServicePrincipalName
    if ($servicePrincipal) {
        Write-Host "The ServicePrincipal is already registered[DisplayName=$ServicePrincipalName]" -ForegroundColor Green
        return
    }
    $newServicePrincipal = Add-ServicePrincipal -SubscriptionId $SubscriptionId -ServicePrincipalName $ServicePrincipalName
    Save-DefaultTfvars -SubscriptionId $SubscriptionId -NewServicePrincipal $newServicePrincipal
}
finally {
    Pop-Location
    az logout
}