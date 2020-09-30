##########################################################
# This script creates the admin user and starts OpenSSH. #
##########################################################

# Make sure Try/Catch blocks work correctly
$ErrorActionPreference = 'Stop'

# The helper Create-NewProfile function was copied from:
# https://gist.github.com/crshnbrn66/7e81bf20408c05ddb2b4fdf4498477d8

#function to register a native method
function Register-NativeMethod {
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$dll,
 
        # Param2 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $methodSignature
    )
 
    $script:nativeMethods += [PSCustomObject]@{ Dll = $dll; Signature = $methodSignature; }
}

function Get-Win32LastError {
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param($typeName = 'LastError')
 if (-not ([System.Management.Automation.PSTypeName]$typeName).Type)
    {
    $lasterrorCode = $script:lasterror | ForEach-Object{
        '[DllImport("kernel32.dll", SetLastError = true)]
         public static extern uint GetLastError();'
    }
        Add-Type @"
        using System;
        using System.Text;
        using System.Runtime.InteropServices;
        public static class $typeName {
            $lasterrorCode
        }
"@
    }
}

#function to add native method
function Add-NativeMethods
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param($typeName = 'NativeMethods')
 
    $nativeMethodsCode = $script:nativeMethods | ForEach-Object { "
        [DllImport(`"$($_.Dll)`")]
        public static extern $($_.Signature);
    " }
 
    Add-Type @"
        using System;
        using System.Text;
        using System.Runtime.InteropServices;
        public static class $typeName {
            $nativeMethodsCode
        }
"@
}

#Main function to create the new user profile
function Create-NewProfile {
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $UserName,
        # Param2 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $Password,
        # Param2 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [string]
        $Description
    )
  
    Write-Verbose "Creating local user $Username";
  
    $secPass = ConvertTo-SecureString "${password}" -AsPlainText -Force
    try {
        New-LocalUser `
            -Name $UserName `
            -Password $secPass `
            -Description $Description `
            -PasswordNeverExpires `
            -AccountNeverExpires;
    } catch {
        Write-Error $_.Exception.Message;
        break;
    }
    $methodName = 'UserEnvCP'
    $script:nativeMethods = @();
 
    if (-not ([System.Management.Automation.PSTypeName]$MethodName).Type) {
        Register-NativeMethod "userenv.dll" "int CreateProfile([MarshalAs(UnmanagedType.LPWStr)] string pszUserSid,`
         [MarshalAs(UnmanagedType.LPWStr)] string pszUserName,`
         [Out][MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszProfilePath, uint cchProfilePath)";
 
        Add-NativeMethods -typeName $MethodName;
    }
 
    $localUser = New-Object System.Security.Principal.NTAccount("$UserName");
    $userSID = $localUser.Translate([System.Security.Principal.SecurityIdentifier]);
    $sb = new-object System.Text.StringBuilder(260);
    $pathLen = $sb.Capacity;
 
    Write-Verbose "Creating user profile for $Username";
 
    try {
        [UserEnvCP]::CreateProfile($userSID.Value, $Username, $sb, $pathLen) | Out-Null;
    } catch {
        Write-Error $_.Exception.Message;
        break;
    }
}

# Helper for adding user to group
function Add-UserToGroup($Username, $Group) {
    $Hostname = (Get-WmiObject Win32_ComputerSystem).Name
    If ((Get-LocalGroupMember $Group).Name -contains "$Hostname\$Username") {
        Write-Host "User '$Username' is already in the '$Group' group!"
    } Else {
        Write-Host "Adding '$Username' to the '$Group' group..."
        Add-LocalGroupMember -Group $Group -Member $Username
    }
}

# Helper for adding a public key to authorized_keys for administrators
function Set-AdminSSHPublicKey($PublicKey) {
    $SSHAuthorizedKeysFile = "C:\ProgramData\ssh\administrators_authorized_keys"
    $PublicKey -f 'string' | Set-Content -Encoding utf8 $SSHAuthorizedKeysFile
    $acl = Get-Acl $SSHAuthorizedKeysFile
    $acl.SetAccessRuleProtection($true, $false)
    $acl.SetAccessRule((New-Object system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","Allow")))
    $acl.SetAccessRule((New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM","FullControl","Allow")))
    $acl.RemoveAccessRule((New-Object system.security.accesscontrol.filesystemaccessrule("NT Authority\Authenticated Users","FullControl","Allow")))
    $acl | Set-Acl
}

#-------------------------------------------------------------------------------

# Template password and SSH key from Terraform
$password = "${password}"
$publickey = "${ssh_key}"

# Set password for admin and make him admin
Create-NewProfile -Username admin -Password $password -Description "Administrator"
Add-UserToGroup -Username admin -Group "Administrators"
Add-UserToGroup -Username admin -Group "Remote Desktop Users"

Write-Host "Installing Scoop package manager..."
iwr -useb get.scoop.sh | iex

Write-Host "Installing Python for Ansible..."
scoop install --global python

# Install OpenSSH
Write-Host "Installing OpenSSH Server..."
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# SSH Add SSH Authorized Keys
Write-Host "Setting the admin public key..."
Set-AdminSSHPublicKey -PublicKey $publickey

# Set default OpenSSH shell to PowerShell
Write-Host "Changing default shell to PowerShell..."
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
    -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -PropertyType String -Force

# Finally start the service
Write-Host "Starting OpenSSH Server..."
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
