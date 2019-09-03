$scriptPath = $MyInvocation.MyCommand.Path
$moduleDir = Split-Path -Parent $scriptPath
$settingsFileName = "settings.json"

Configuration SetConfiguration
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        Script OpenPort
        {
            GetScript = {
                param(
                    [string]$fwRuleName,
                    [string]$remoteIp
                )
                $rule = Get-NetFirewallRule -Name "$fwRuleName" -ErrorAction SilentlyContinue
                if(!$rule){
                    Write-Verbose -Message "Rule NOT found[name=$fwRuleName]"
                    return $false
                }
                if($rule.Direction -ne 'Inbound'){
                    Write-Verbose -Message "Rule settings are different[name=$fwRuleName, Direction]"
                    return $false
                }
                if($rule.Protocol -ne 'Any'){
                    Write-Verbose -Message "Rule settings are different[name=$fwRuleName, Protocol]"
                    return $false
                }
                if($rule.Action -ne 'Allow'){
                    Write-Verbose -Message "Rule settings are different[name=$fwRuleName, Action]"
                    return $false
                }
                if($rule.Enabled -ne $true){
                    Write-Verbose -Message "Rule settings are different[name=$fwRuleName, Enabled]"
                    return $false
                }
                $filter = $rule | Get-NetFirewallAddressFilter
                if(!$filter){
                    Write-Verbose -Message "Rule filter NOT found[name=$fwRuleName]"
                    return $false
                }
                if($filter.RemoteAddress -ne $remoteIp){
                    Write-Verbose -Message "Rule filter settings are different[name=$fwRuleName, RemoteAddress]"
                    return $false
                }
                Write-Verbose -Message "Rule found[name=$fwRuleName]"
                return $true
            }
            TestScript = {
                Write-Verbose -Message "Push-Location $using:moduleDir"
                Push-Location $using:moduleDir
                try{
                    $settingsJson = Get-Content -Path $using:settingsFileName
                    $settings = $settingsJson | ConvertFrom-Json
                    Write-Verbose -Message "json=$settingsJson"
                
                    foreach($rule in $settings.firewallRules){
                        $isRuleExpected = [scriptblock]::Create($GetScript).Invoke($rule.name, $rule.remoteIp)
                        if(!$isRuleExpected){
                            Write-Verbose -Message "Firewall rules are NOT yet set"
                            return $false
                        }
                    }
                    Write-Verbose -Message "Firewall rules are already set"
                    return $true
                }finally{
                    Pop-Location
                }
            }
            SetScript = {
                Write-Verbose -Message "Push-Location $using:moduleDir"
                Push-Location $using:moduleDir
                try{
                    $settingsJson = Get-Content -Path $using:settingsFileName
                    $settings = $settingsJson | ConvertFrom-Json
                    Write-Verbose -Message "json=$settingsJson"
                
                    $settings.firewallRules | ForEach-Object {
                        $name = $_.name
                        $remoteIp = $_.remoteIp
                        $rule = Get-NetFirewallRule -Name "$name" -ErrorAction SilentlyContinue
                        if($rule){
                            Write-Verbose -Message "update firewall rule[name=$name]"
                            Set-NetFirewallRule -Name "$name" -Direction Inbound -Action Allow -Protocol Any -RemoteAddress "$remoteIp" -Enabled:True
                        }else{
                            Write-Verbose -Message "new firewall rule[name=$name]"
                            New-NetFirewallRule -Name "$name" -DisplayName "$name" -Direction Inbound -Action Allow -Protocol Any -RemoteAddress "$remoteIp" -Enabled:True
                        }
                    }
                    Write-Verbose -Message "OpenPort operation is complete"
                }finally{
                    Pop-Location
                }
            }
        }
        Script Registry
        {
            GetScript = {
                param(
                    [string]$key,
                    [string]$propertyName
                )
                $registry = Get-ItemProperty -Path "$key" -ErrorAction Continue
                return $registry."$propertyName"
            }
            TestScript = {
                Write-Verbose -Message "Push-Location $using:moduleDir"
                Push-Location $using:moduleDir
                try{
                    $settingsJson = Get-Content -Path $using:settingsFileName
                    $settings = $settingsJson | ConvertFrom-Json
                    Write-Verbose -Message "json=$settingsJson"
                
                    foreach($registry in $settings.registrySettings){
                        $currentSetting = [scriptblock]::Create($GetScript).Invoke($registry.key, $registry.propertyName)
                        if($currentSetting -ne $registry.value){
                            Write-Verbose -Message "Registry[$($registry.key)] is NOT set yet"
                            return $false
                        }
                    }
                    Write-Verbose -Message "Registries are already set"
                    return $true
                }finally{
                    Pop-Location
                }
            }
            SetScript = {
                Write-Verbose -Message "Push-Location $using:moduleDir"
                Push-Location $using:moduleDir
                try{
                    $settingsJson = Get-Content -Path $using:settingsFileName
                    $settings = $settingsJson | ConvertFrom-Json
                    Write-Verbose -Message "json=$settingsJson"
                
                    foreach($registry in $settings.registrySettings){
                        Write-Verbose -Message "Update $($registry.key).$($registry.propertyName) = $($registry.value)"
                        New-ItemProperty -Path "$($registry.key)" -Name "$($registry.propertyName)" -PropertyType DWORD -Value "$($registry.value)" -Force
                
                    }
                    // reboot
                    $global:DSCMachineStatus = 1
                }finally{
                    Pop-Location
                }
            }
        }
    }
}