$ErrorActionPreference = "Stop"

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath

$installCmd = "Push-Location $scriptDir;Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi;Start-Process msiexec.exe -Wait -ArgumentList ''/I AzureCLI.msi /quiet''"

PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -Command ""${installCmd}""' -Verb RunAs}";
