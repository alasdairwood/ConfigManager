<#
# create some folders and shares, windows-noob.com 2016/3/30
# 
#>

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "exiting this script."
    Break
}
# specify the drive letter that you want the folders created on
$SourcesDrive = "S:"
# specify the ConfigMgr Admin
$DomainName = "aiwtech"
$CMAdmin = "$DomainName\Administrator"
# Give the CMAdmin access to the following folders
$OSDBootImagePath = "$SourcesDrive\SCCM\OSD"
icacls $OSDBootImagePath /grant $CMAdmin":(OI)(CI)(M)"
# create some folders
New-Item -Path "$SourcesDrive\Backups" -ItemType Directory
New-Item -Path "$SourcesDrive\Captures" -ItemType Directory
New-Item -Path "$SourcesDrive\Hidden" -ItemType Directory
New-Item -Path "$SourcesDrive\USMTStores" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\OSD" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\OSD\Boot" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\OSD\DriverPackages" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\OSD\Drivers" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\OSD\MDT\MDT2013u2\Toolkit" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\OSD\MDT\MDT2013u2\Settings" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\OSD\OS" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\OSD\OS\OSImages\Windows10x64\1511" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\OSD\OS\OSUpgradePackages\Windows10x64\1511" -ItemType Directory
New-Item -Path "$SourcesDrive\Sources\Apps\Microsoft" -ItemType Directory


# create some shares
New-SmbShare –Name Captures$ –Path $SourcesDrive\Captures -ChangeAccess EVERYONE
icacls $SourcesDrive\Captures /grant $DomainName\CM_BA':(OI)(CI)(M)'
New-SmbShare –Name Sources –Path $SourcesDrive\Sources -FullAccess EVERYONE
New-SmbShare –Name USMTStore$ –Path $SourcesDrive\USMTStores -FullAccess EVERYONE
New-SmbShare –Name Backup$ –Path $SourcesDrive\Backups -FullAccess EVERYONE

