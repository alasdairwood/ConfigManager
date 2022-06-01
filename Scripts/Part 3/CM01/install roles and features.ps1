<#
# Install Web Server (IIS) roles and features for ConfigMgr, 2019/4/15 Niall Brady, https://www.windows-noob.com/forums/topic/16614-how-can-i-install-system-center-configuration-manager-current-branch-version-1902-on-windows-server-2019-with-sql-server-2017-part-1/
#
# This script:            Install roles and features for ConfigMgr https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/site-and-site-system-prerequisites
# Before running:         Insert the Windows Server 2019 media, and if necessary modify the variables (lines 18-20) 
# Usage:                  Run this script on the ConfigMgr Primary Server as a user with local Administrative permissions on the server
#>

function TestPath($Path) {
if ( $(Try { Test-Path $Path.trim() } Catch { $false }) ) {
   write-host "Path OK"
 }
Else {
   write-host "$Path not found, please fix and try again."
   break
 }}

$XMLpath = "C:\Scripts\Part 3\CM01\DeploymentConfigTemplate.xml"
$SourceFiles = "D:\Sources\SXS"
$LogFile = "C:\Windows\Temp\InstallIISRole.log"

    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] “Administrator”))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

# check if the XML is found

$Path = $XMLpath
TestPath $Path

# check is media found
 
$Path = $SourceFiles
TestPath $Path

Write-Host "Installing roles and features, please wait... "  -nonewline
Install-WindowsFeature -ConfigurationFilePath $XMLpath -Source $SourceFiles -LogPath $LogFile -Verbose
Write-Host "Exiting script"