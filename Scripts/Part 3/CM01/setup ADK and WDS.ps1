<#
# Install Windows ADK 1809, Windows PE Addon and WDS for SCCM 1902 CB, 2019/4/15, Niall Brady. For more info see > https://www.windows-noob.com/forums/topic/16614-how-can-i-install-system-center-configuration-manager-current-branch-version-1902-on-windows-server-2019-with-sql-server-2017-part-1/
#
# This script:            Downloads and installs Windows ADK 1809, then downloads the Windows ADK Window PE Addon. Next, installs WDS for ConfigMgr https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/site-and-site-system-prerequisites
# Before running:         Modify the ADK download path source variable (line 17), if you have already downloaded the ADK manually copy the content of "Windows Kits" to the source folder
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
$SourcePath = "S:\Sources"

    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] “Administrator”))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

# create Source folder if needed
if (Test-Path $SourcePath){
 write-host "The Source folder already exists."
 } else {

New-Item -Path $SourcePath -ItemType Directory
}
# These 3 lines with help from Trevor !
$ADKPath = '{0}\Windows Kits\11\ADK' -f $SourcePath;
$ADKPath2 = '{0}\Windows Kits\11\ADK\Installers\Windows PE x86 x64-x86_en-us.msi' -f $SourcePath;
$ArgumentList1 = '/layout "{0}" /quiet' -f $ADKPath;

# Check if these files exists, if not, download them
 $file1 = $SourcePath+"\adksetup.exe"
 $file2 = $SourcePath+"\adkwinpesetup.exe"

 #write-host $ADKPath "..." $ADKPath2
 #break

if (Test-Path $file1){
 write-host "The file $file1 exists."
 } else {
 
# Download Windows Assessment and Deployment Kit (ADK Windows 11)
		Write-Host "Downloading Adksetup.exe " -nonewline
		$clnt = New-Object System.Net.WebClient
		$url = "https://go.microsoft.com/fwlink/?linkid=2165884"
		$clnt.DownloadFile($url,$file1)
		Write-Host "done!" -ForegroundColor Green
 }

if (Test-Path $ADKPath){
 Write-Host "The folder $ADKPath exists, skipping download"
 } else{
 
Write-Host "Downloading Windows ADK 11, please wait..."  -nonewline
Start-Process -FilePath $file1 -Wait -ArgumentList $ArgumentList1
Write-Host "done!" -ForegroundColor Green
 }
 
Start-Sleep -s 3

# Download the ADK 11 Windows PE Addon
		Write-Host "Downloading Adkwinpesetup.exe " -nonewline
		$clnt = New-Object System.Net.WebClient
		$url = "https://go.microsoft.com/fwlink/?linkid=2166133"
		$clnt.DownloadFile($url,$file2)
		Write-Host "done!" -ForegroundColor Green
 

if (Test-Path $ADKPath2){
 Write-Host "The file $ADKPath2 exists, skipping download"
 } else{
 
Write-Host "Downloading the Windows PE addon for Windows ADK 11, please wait..."  -nonewline
Start-Process -FilePath $file2 -Wait -ArgumentList $ArgumentList1
Write-Host "done!" -ForegroundColor Green
 }
 
Start-Sleep -s 10

# This installs Windows Deployment Service
Write-Host "Installing Windows Deployment Services..."  -nonewline
Import-Module ServerManager
Install-WindowsFeature -Name WDS -IncludeManagementTools
Start-Sleep -s 10

# Install ADK Deployment Tools
Write-Host "Installing Windows ADK 11..."
Start-Process -FilePath "$ADKPath\adksetup.exe" -Wait -ArgumentList " /Features OptionId.DeploymentTools OptionId.ImagingAndConfigurationDesigner OptionId.UserStateMigrationTool /norestart /quiet /ceip off"
Start-Sleep -s 20
Write-Host "Done !"

# Install Windows Preinstallation Enviroment
Write-Host "Installing Windows Preinstallation Enviroment..."
Start-Process -FilePath "$ADKPath\adkwinpesetup.exe" -Wait -ArgumentList " /Features OptionId.WindowsPreinstallationEnvironment /norestart /quiet /ceip off"
Start-Sleep -s 20
Write-Host "Done !"
