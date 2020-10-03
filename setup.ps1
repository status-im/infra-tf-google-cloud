##############################################################
# This script enables Administrator user and starts OpenSSH. #
##############################################################

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

#-----------------------------------------------------------

Write-Host ">>> START: Initial Bootstrapping Script"

# Make sure Try/Catch blocks work correctly
$ErrorActionPreference = 'Stop'

# Template SSH key from Terraform
$password = "${password}" | ConvertTo-SecureString -AsPlainText -Force
$publickey = "${ssh_key}"

Write-Host "Enable Administrator account..."
Set-LocalUser -Name Administrator -Password $password
Enable-LocalUser -Name Administrator

Write-Host "Installing Scoop package manager..."
iwr -useb get.scoop.sh | iex

Write-Host "Installing Python and Git for Ansible..."
scoop install --global python git

# Install OpenSSH
Write-Host "Installing OpenSSH Server..."
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# SSH Add SSH Authorized Keys
Write-Host "Setting the admin public key..."
Set-AdminSSHPublicKey -PublicKey $publickey

# Set default OpenSSH shell to PowerShell
Write-Host "Changing default shell to PowerShell..."
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
    -Value "C:\ProgramData\scoop\apps\git\current\bin\bash.exe" `
    -PropertyType String -Force

# Finally start the service
Write-Host "Starting OpenSSH Server..."
Set-Service -Name sshd -StartupType 'Automatic'

Write-Host ">>> END: Initial Bootstrapping Script"
