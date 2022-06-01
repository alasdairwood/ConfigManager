<#
# Download SCCM prerequisite files, 2019/4/23 Niall Brady, https://www.windows-noob.com
#
# This script:            Downloads SCCM prerequisite files
# Before running:         Extract the SCCM Current Branch baseline version ISO to the $SCCMPath folder, eg: C:\Source\SCCM1902. Edit the variables as necessary (lines 17-19). 
# Usage:                  Run this script on the ConfigMgr Primary Server as a user with local Administrative permissions on the server
#>
  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] “Administrator”))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

# below variables are customizable
$SourcePath = "S:\Sources\SCCM"
# where is the media ?
$SCCMPath = "D:"
$PrerequisitesPath = "$SourcePath" + "\SCCMPrereqs"
# please don't edit below this line
write-host "Starting SCCM prerequisites download script..."
write-host ""

# Check for SCCM source files
write-host "Checking for ConfigMgr media in $SCCMPath..." -nonewline
if (Test-Path "$SCCMPath\SMSSETUP"){
Write-Host "done!" -ForegroundColor Green
 } else {
write-host "Error" -ForegroundColor Red
write-host "Please extract the SCCM media to '$SCCMPath' and then try running this script again..."
break}

write-host "Checking for'$PrerequisitesPath' folder..." -nonewline

# Check for prerequisites download path folder, if not present create it
if (Test-Path "$PrerequisitesPath"){
 Write-Host "done!" -ForegroundColor Green
 #write-host "The folder '$PrerequisitesPath' already exists, therefore this script will not download the prerequisites."
 
 } else {
mkdir "$PrerequisitesPath" | out-null
Write-Host "done!" -ForegroundColor Green
# start the SCCM prerequisite downloader
write-host "Downloading SCCM version prerequisite files..." -nonewline
$filepath = "$SCCMPath\SMSSETUP\bin\X64\SETUPDL.exe"
# remove /NoUI if you want to see the download progress UI
$Parms = "/NoUI `"$PrerequisitesPath`""
$Prms = $Parms.Split(" ")

Try
{& "$filepath" $Prms | Out-Null}
catch
{Write-Host "error!" -ForegroundColor red
break}
Write-Host "done!" -ForegroundColor Green
}