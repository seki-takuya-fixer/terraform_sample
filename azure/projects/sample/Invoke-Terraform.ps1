$ErrorActionPreference = "Stop"

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
Push-Location $scriptDir

try {
    $terraformExe = "../../../setup/terraform_0.12.6_windows_amd64/terraform.exe"

    #Initialize
    Invoke-Expression "$terraformExe init"

    #Apply
    $tfvars = Get-ChildItem | Where-Object { $_.Name -like "*.tfvars" }
    $tfvars += Get-Item "../../../setup/azure_sp.tfvars"
    $tfvarArgs = ($tfvars | Select-Object @{Name = "Name"; Expression = { "-var-file $($_.FullName)" } }).Name -join " "
    Invoke-Expression "$terraformExe apply $tfvarArgs -state=`"terraform.tfstate`""
}
finally {
    Pop-Location
}