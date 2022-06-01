<#
# Configure ADDS, 2019/4/10 Niall Brady, https://www.windows-noob.com
#
# This script:            Configures AD DS Deployment (https://docs.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest?view=win10-ps), DHCP server and DNS
# Before running:         Configure the variables below (lines 17-32)
# Usage:                  Run this script as Administrator on a WorkGroup joined server that is destined to become the ADDC
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] “Administrator”))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

$DomainName = "bts.lab.local"
$DomainNetbiosName = "BTS"
$SafeModeAdministratorPassword = convertto-securestring "Emerald21$" -asplaintext -force
$DomainMode = "WinThreshold"
$ForestMode = "WinThreshold"
$DatabasePath = "C:\Windows\NTDS"
$LogPath = "C:\Windows\NTDS"
$SysVolPath = "C:\Windows\SYSVOL"
$DHCPServerIP="10.44.1.10"
$DNSServerIP="10.44.1.10"
$StartRange="10.44.1.100"
$EndRange="10.44.1.120"
$Subnet="255.255.255.0"
$Router="10.44.1.254"
$DHCPScriptPath="C:\Scripts\Part 1\DC01\InstallDHCP.ps1"
$Logfile = "C:\Windows\Temp\ConfigureADDS.log"

Function LogWrite
{
   Param ([string]$logstring)
   $a = Get-Date
   $logstring = $a,$logstring
   Try
{   
    Add-content $Logfile -value $logstring -ErrorAction silentlycontinue
}
Catch
{
    $logstring="Invalid data encountered"
    Add-content $Logfile -value $logstring
}
   write-host $logstring
}

LogWrite "Starting script.."

# creates a runonce job to run the following DHCP script on next logon
LogWrite "creating runonce job for the DHCP installer"
$DHCPScript = @"
# install the DHCP server role
Install-WindowsFeature -Name 'DHCP' -IncludeManagementTools
Add-DhcpServerInDC -DnsName $DomainName -IPAddress $DHCPServerIP
Add-DhcpServerInDC -DnsName $Env:COMPUTERNAME
Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2
Add-DhcpServerV4Scope -Name 'DHCP Scope' -StartRange $StartRange -EndRange $EndRange -SubnetMask $Subnet
Set-DhcpServerV4OptionValue -DnsDomain $DomainName -DnsServer $DNSServerIP -Router $Router 
Set-DhcpServerv4Scope -ScopeId $DHCPServerIP -LeaseDuration 1.00:00:00
"@ 

if (Test-Path "$DHCPScriptPath"){
 write-host "'$DHCPScriptPath' already exists, will not recreate it."
 } else {
New-Item -Path "$DHCPScriptPath" -ItemType File -Value $DHCPScript
}

# create the runonce item
$DHCPScriptPath
$RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
set-itemproperty $RunOnceKey "NextRun" ('C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -executionPolicy Unrestricted -File ' + "`"$DHCPScriptPath`"")

LogWrite "Installing ADDS"

# install ADDS
Install-windowsfeature -name AD-Domain-Services –IncludeManagementTools 2>&1
LogWrite "Importing ADDSDeployment module"
Import-Module ADDSDeployment
LogWrite "Installing ADDSForest"
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath $DatabasePath `
-DomainMode $DomainMode `
-DomainName $DomainName `
-DomainNetbiosName $DomainNetbiosName `
-ForestMode $ForestMode `
-InstallDns:$true `
-LogPath $LogPath `
-NoRebootOnCompletion:$false `
-SysvolPath $SysVolPath `
-SafeModeAdministratorPassword $SafeModeAdministratorPassword `
-Force:$true

