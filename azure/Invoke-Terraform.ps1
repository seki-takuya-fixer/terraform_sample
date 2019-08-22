param(
    [string]$TerraformExe = "..\setup\terraform_0.12.6_windows_amd64\terraform.exe"
)
$ErrorActionPreference = "Stop"

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
Push-Location $scriptDir

try {
    #Initialize
    Invoke-Expression "$TerraformExe init"

    #Apply
    $tfvars = Get-ChildItem | Where-Object { $_.Name -like "*.tfvars" }
    $tfvarArgs = ($tfvars | Select-Object @{Name = "Name"; Expression = { "-var-file $($_.Name)" } }).Name -join " "
    Invoke-Expression "$TerraformExe apply $tfvarArgs"
}
finally {
    Pop-Location
}