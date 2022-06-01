<#
# Extend the Schema in AD for SCCM (Current Branch) version 1902, 2019/4/23 Niall Brady, https://www.windows-noob.com
#
# This script:            Optionally extends the schema for SCCM
# Before running:         Make sure the $SCCMPath variable points to the location of the 1802 ISO (or extracted media). Edit the variables as necessary (lines 16-45). 
# Usage:                  Run this script on the ConfigMgr Primary Server as a user with local Administrative permissions on the server
#>
  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] “Administrator”))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

# below variables are customizable
$SourcePath = "S:\Sources"
# where is the media mounted ?
$SCCMPath = "D:"

# please don't edit below this line

# Check for SCCM source files
write-host "Looking for ConfigMgr media in '$SCCMPath'..." -nonewline
if (Test-Path "$SCCMPath\SMSSETUP"){
Write-Host "done!" -ForegroundColor Green
 } else {
write-host "Error" -ForegroundColor Red
write-host "Please extract the SCCM media to '$SCCMPath' and then try running this script again..."
break}

$answer = Read-Host "Extend the schema ?" 

while("yes","no","y","n" -notcontains $answer)
{
	$answer = Read-Host "Yes No"
}
if ($answer -eq "No" -or $answer -eq "n"){
write-host "skipping schema extension"
}
else
{   $Credential = $Host.ui.PromptForCredential("Need credentials", "Please enter suitable administrative credentials for extending the schema.", "", "NetBiosUserName")
    # extend the schema 
    write-host "about to extend the schema..." -nonewline
    $filepath = "$SCCMPath\SMSSETUP\bin\X64\extadsch.exe"

Try
    {Start-Process "$filepath" -Credential $Credential | Out-Null}
    catch
    {Write-Host "Sorry but there was an error extending the schema, are you sure the credentials were correct!" -ForegroundColor red
    break}
    Write-Host "done!" -ForegroundColor Green
    Start-Sleep 30
}
