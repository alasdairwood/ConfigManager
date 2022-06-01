<#
# Create the System Management container, 2019/4/12 Niall Brady, https://www.windows-noob.com
#
# This script:            Creates the System Management container, for more info see https://www.windows-noob.com/forums/topic/16614-how-can-i-install-system-center-configuration-manager-current-branch-version-1902-on-windows-server-2019-with-sql-server-2017-part-1/
# Before running:         Is it time for a beer yet ?
# Usage:                  Run this script as Administrator on the DC
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] “Administrator”))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

# Get the distinguished name of the Active Directory domain
$DomainDn = ([adsi]"").distinguishedName
# Build distinguished name path of the System container
$SystemDn = "CN=System," + $DomainDn
# Retrieve a reference to the System container using the path we just built
$SysContainer = [adsi]"LDAP://$SystemDn"
$SystemManagementContainer = "ad:CN=System Management,CN=System,$DomainDn" 

 If (!(Test-Path $SystemManagementContainer)) { 
 # Create a new object inside the System container called System Management, of type "container"
  write-host "Creating System Management container..."
  $SysMgmtContainer = $SysContainer.Create("Container", "CN=System Management")

# Commit the new object to the Active Directory database
$SysMgmtContainer.SetInfo()}
else{
write-host "System Management container already exists..."}
write-host "All done."
