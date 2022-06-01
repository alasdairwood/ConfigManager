<#
# Create Users/Usergroups and OUs, 2019/4/11 Niall Brady, https://www.windows-noob.com
#
# This script:            Creates users/usergroups and ou's in AD, see https://www.windows-noob.com/forums/topic/16614-how-can-i-install-system-center-configuration-manager-current-branch-version-1902-on-windows-server-2019-with-sql-server-2017-part-1/ for details.
# Before running:         Configure the variables below (lines 79-100)
# Usage:                  Run this script as Administrator on the DC
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] “Administrator”))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

function ADDOU($OUName, $OUPath) {
   try {$IsOUInAD=Get-ADOrganizationalUnit -Identity "OU=$OUName,$OUPath" 
         write-host "The $OUNAme OU was already found in AD."
        }
    catch {
   write-host "About to add the following OU: " -ForegroundColor White -NoNewline 
   write-host $OUName -ForegroundColor Green -NoNewLine
   write-host -ForegroundColor White " to this OUPath: " -NoNewLine
   write-host $OUPath -ForegroundColor Green -NoNewLine
            New-ADOrganizationalUnit -Name $OUName -Path $OUPath
            write-host " Done !" -ForegroundColor White}
}

function ADDUser($User, $DistinguishedName, $SelectedOU) {


    try {$IsUsserInAD=Get-ADUser -LDAPFilter "(sAMAccountName=$User)"
        If ($IsUsserInAD -eq $Null) 
            {write-host "User $User does not exist in AD, adding..." -NoNewline
            New-ADUser -Name $User -GivenName $User -SamAccountName $User -UserPrincipalName $User$DistinguishedName -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Path $SelectedOU -PassThru | Enable-ADAccount
            # -ErrorAction Stop -Verbose
            write-host "Done !" -ForegroundColor Green}
        Else {
            write-host "User $User was already found in AD."
             }
        }
        catch{
   write-host "About to add the following User: " -ForegroundColor White -NoNewline 
   write-host $User -ForegroundColor Green -NoNewLine
   write-host -ForegroundColor White " to this DistinguishedName: " -NoNewLine
   write-host $SelectedOU -ForegroundColor Green
            }  
}  

function ADDUserGroup($UserGroup, $SelectedOU) {
    try {$IsUserGroupInAD=Get-ADGroup -LDAPFilter "(sAMAccountName=$UserGroup)"
        If ($IsUserGroupInAD -eq $Null) 
            {write-host "UserGroup $UserGroup does not exist in AD, adding..." -NoNewline
            New-ADGroup -Name $UserGroup -DisplayName $UserGroup -SamAccountName $UserGroup -GroupCategory Security -GroupScope Global -Path $SelectedOU
             
            # -ErrorAction Stop -Verbose
            write-host "Done !" -ForegroundColor Green}
        Else {
            write-host "UserGroup $UserGroup was already found in AD."
             }
        }
        catch{
            write-host "Error adding UserGroup: " $UserGroup -ForegroundColor Red
            }  
}  

#clear
try {
    Import-Module ActiveDirectory
    }
    catch {
    Write-host "The Active Directory module was not found, try running this on the DC."
    }

#
# define these variables
#
$DistinguishedName="DC=bts,DC=lab,DC=local"
$OUroot="bts"
$OUchild=@("Security Groups","Servers","Service Accounts","Users","Workstations")
$OUchild2=@("SCCM","MDT","MBAM")
$Password = "Emerald21$"
# Users
$YourUserName = "Alasdair"
$CMUsers = @("CM_BA", "CM_CP", "CM_JD", "CM_NAA", "CM_RS", "CM_TS", "CM_WS")
$MDTUsers = @("MDT_BA", "MDT_JD")
$RegularUsers = @("$YourUserName", "testuser1", "testuser2", "testuser3")
$MBAMUsers = @("MBAM_DB_RO","MBAM_HD_AppPool","MBAM_Reports_Compl")
# UserGroups
$MBAMUserGroups = @("MBAM_DB_RW","MBAM_HD", "MBAM_HD_Adv", "MBAM_HD_Report", "MBAM_Reports_RO")
# the below 4 variables are for adding YourUserName as local admin on the ConfigMgr server, 
# you must have first configured the following GPO on the domain controller
# "Windows Firewall: Allow inbound file and printer sharing exception: Enabled"
# otherwise disable the lines at the bottom of this script.
  
$Server = "BTSCM01"
$Group = "Administrators"
$Domain = "bts.lab.local"

#
# add root OU
#

write-host "Adding the root OU..." -ForegroundColor yellow

$OUName=$OUroot
$OUPath=$DistinguishedName

ADDOU $OUName $OUPath

#
# add 2ndlevel OUs
#

write-host "Adding child OU's..." -ForegroundColor yellow

$OUName=$OUchild
$OUPath="OU=" + $OUroot + "," + $DistinguishedName  

# create an array of OUs to add to AD
foreach($OU in $OUchild){
            ADDOU $OU $OUPath
} 

write-host "Adding more child OU's..." -ForegroundColor yellow
# add 3rdlevel OUs
#
$OUName=$OUchild2
$OUPath="OU=Service Accounts,OU=" + $OUroot + "," + $DistinguishedName

# create an array of OUs to add to AD
foreach($OU in $OUchild2){
            ADDOU $OU $OUPath
}  


# add ConfigMgr users
#

$SelectedOU="OU=SCCM,OU=Service Accounts,OU=$OURoot," + $DistinguishedName

write-host "Adding Users to " -ForegroundColor yellow -NoNewline
write-host $SelectedOU -ForegroundColor green


foreach($User in $CMUsers){
ADDUser $User $DistinguishedName $SelectedOU
                             }
# add MDT users
#

$SelectedOU="OU=MDT,OU=Service Accounts,OU=$OURoot," + $DistinguishedName

write-host "Adding Users to " -ForegroundColor yellow -NoNewline
write-host $SelectedOU -ForegroundColor green
foreach($User in $MDTUsers){
ADDUser $User $DistinguishedName $SelectedOU
                             }

# add MBAM users
#

$SelectedOU="OU=MBAM,OU=Service Accounts,OU=$OURoot," + $DistinguishedName

write-host "Adding Users to " -ForegroundColor yellow -NoNewline
write-host $SelectedOU -ForegroundColor green
foreach($User in $MBAMUsers){
ADDUser $User $DistinguishedName $SelectedOU
                             }

# add Regular users
#

$SelectedOU="OU=Users,OU=$OURoot," + $DistinguishedName

write-host "Adding Users to " -ForegroundColor yellow -NoNewline
write-host $SelectedOU -ForegroundColor green
foreach($User in $RegularUsers){
ADDUser $User $DistinguishedName $SelectedOU
                           }


$SelectedOU="OU=MBAM,OU=Service Accounts,OU=$OURoot," + $DistinguishedName
# create an array of usergroups to add to AD
write-host "Adding UserGroups to " -ForegroundColor yellow -NoNewline
write-host $SelectedOU -ForegroundColor green

foreach($UserGroup in $MBAMUserGroups){
ADDUserGroup $UserGroup $SelectedOU
                             }

# add YourUserName as local admin on ConfigMgr server
write-host "Adding "  -ForegroundColor yellow -NoNewline
write-host $YourUserName -ForegroundColor green -NoNewline
write-host " as a Local administrator on " -ForegroundColor yellow -NoNewline
write-host $Server -ForegroundColor green
try {([ADSI]"WinNT://$Server/$Group,group").psbase.Invoke("Add",([ADSI]"WinNT://$domain/$YourUserName").path)}
catch {write-host "Oops that'd didn't work, did you enable the following GPO ?"  -ForegroundColor red
write-host " Allow Inbound File and Printer sharing exception which sets Windows Firewall: Allow inbound file and printer sharing exception to Enabled. " -ForegroundColor white}
#
write-host "All done !" -ForegroundColor Yellow