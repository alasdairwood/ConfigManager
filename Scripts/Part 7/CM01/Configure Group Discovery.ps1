<#
# Configure Group Discovery, 2019/8/27 Niall Brady, for more info see https://www.windows-noob.com/forums/topic/16614-how-can-i-install-system-center-configuration-manager-current-branch-version-1902-on-windows-server-2019-with-sql-server-2017-part-1/
#
# This script:            configures Group Discovery
# Before running:         Edit the variables as necessary (lines 28-50).
# Usage:                  Run this script on the ConfigMgr Primary Server as the user with local Administrative permissions on the server
#>
  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

Function Get-CmConsolePath {
        $location = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\SMS\Setup" | 
            Select-Object -ExpandProperty "UI Installation Directory"
        $Cmconsolepath = "$location\bin\ConfigurationManager.psd1"
        if (Test-Path $Cmconsolepath) {
            return $Cmconsolepath
        }
    }

# below variables are customizable

#
# schedule https://docs.microsoft.com/en-us/powershell/module/configurationmanager/new-cmschedule?view=sccm-ps
#
$SiteCode = "BTS"
$StartDate = "2022/03/22 00:00:00"
$EndDate = "2025/12/31 00:00:00"
$RecurInterval = "days" # can be Minutes, Hours, days
$RecurCount = "1" # max 59

# Active directory Group discovery method applicable variables
$Enabled = $True
$AddGroupDiscoveryScope = $True
$RecursiveSearch = $True
$OUDistinguishedName ="OU=bts,DC=bts,DC=lab,DC=local"
$OUParentName = "Active Directory Group Discovery - $SiteCode"
$LdapLocation = "LDAP://$($OUDistinguishedName)"
$ADGScope=New-CMADGroupDiscoveryScope -Name $OUParentName -LdapLocation $LdapLocation -RecursiveSearch $RecursiveSearch
$DiscoverDistributionGroupMembership = $True
$EnableDeltaDiscovery = $True
$DeltaDiscoveryMins = 5
$EnableFilteringExpiredLogon = $True
$EnableFilteringExpiredPassword = $True
$TimeSinceLastLogonDays = 90
$TimeSinceLastPasswordUpdateDays = 90

#
# connect to ConfigMgr
#

$console=Get-CmConsolePath
Import-Module $console
$SiteCode=Get-PSDrive -PSProvider CMSite
write-host "Connecting to " -ForegroundColor White -NoNewline
write-host $SiteCode -ForegroundColor Green -NoNewLine
cd "$($SiteCode):"
write-host ", done." -ForegroundColor White

# configure the discovery method...

$Schedule = New-CMSchedule -RecurInterval $RecurInterval -Start $StartDate -End $EndDate -RecurCount $RecurCount
#write-host $schedule -Verbose

write-host "Enabling: " -ForegroundColor White -NoNewline
write-host "ActiveDirectoryGroupDiscovery" -ForegroundColor Green -NoNewLine
Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode $SiteCode -Enabled $Enabled -AddGroupDiscoveryScope $ADGScope -PollingSchedule $Schedule -DiscoverDistributionGroupMembership $DiscoverDistributionGroupMembership -EnableDeltaDiscovery $EnableDeltaDiscovery -DeltaDiscoveryMins $DeltaDiscoveryMins -TimeSinceLastLogonDays $TimeSinceLastLogonDays -TimeSinceLastPasswordUpdateDays $TimeSinceLastPasswordUpdateDays -EnableFilteringExpiredPassword $EnableFilteringExpiredPassword -EnableFilteringExpiredLogon $EnableFilteringExpiredLogon #-Verbose
write-host ", done." -ForegroundColor White