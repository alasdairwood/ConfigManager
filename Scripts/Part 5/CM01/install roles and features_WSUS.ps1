<#
# Installs WSUS role, 2019/4/23 Niall Brady, https://www.windows-noob.com/forums/topic/16114-how-can-i-install-system-center-configuration-manager-current-branch-version-1802-on-windows-server-2016-with-sql-server-2017-part-1/
#
# This script:            Installs WSUS role for ConfigMgr
# Before running:         Ensure the Server 2019 iso is in the location specified in the variables.
# Usage:                  Run this script on the ConfigMgr Primary Server as a user with local Administrative permissions on the server
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] “Administrator”))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }
$XMLpath = "C:\Scripts\Part 5\CM01\DeploymentConfigTemplate_WSUS.xml"
$WSUSFolder = "S:\WSUS"
$SourceFiles = "D:\Sources\SXS"
$ServerName="BTSCM01"
# create WSUS folder
if (Test-Path $WSUSFolder){
 write-host "The WSUS folder already exists."
 } else {

New-Item -Path $WSUSFolder -ItemType Directory
}
if (Test-Path $SourceFiles){
 write-host "Windows Server 2019 source files found"
 } else {

write-host "Windows Server 2019 source files not found, aborting"
break
}

Write-Host "Installing roles and features, please wait... "  -nonewline
Install-WindowsFeature -ConfigurationFilePath $XMLpath -Source $SourceFiles
Start-Sleep -s 10
write-host "Configuring SUSDB in SQL and WSUS content location..."
& ‘C:\Program Files\Update Services\Tools\WsusUtil.exe’ postinstall SQL_INSTANCE_NAME=$ServerName CONTENT_DIR=$WSUSFolder |out-file Null
write-host "All done !"