#Requires -RunAsAdministrator

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "        USER CREATION SCRIPT" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$Username = Read-Host "Enter username"
$Fullname = Read-Host "Enter full name"
$Password = Read-Host "Enter password" -AsSecureString
$PasswordConfirm = Read-Host "Confirm password" -AsSecureString

# Validate password match
$PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
)
$PlainConfirm = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordConfirm)
)

if ($PlainPassword -ne $PlainConfirm) {
    Write-Host "❌ Passwords do not match. Exiting..." -ForegroundColor Red
    exit 1
}

# Check if user already exists
if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
    Write-Host "❌ User '$Username' already exists!" -ForegroundColor Red
    exit 1
}

# Create the local user
New-LocalUser -Name $Username -Password $Password -FullName $Fullname -PasswordNeverExpires $false | Out-Null

Write-Host "✅ User '$Username' created successfully!" -ForegroundColor Green

# Ask for admin privileges
$SudoAccess = Read-Host "Should this user have administrator privileges? (y/n)"
if ($SudoAccess -eq "y" -or $SudoAccess -eq "Y") {
    Add-LocalGroupMember -Group "Administrators" -Member $Username
    Write-Host "✅ User added to Administrators group." -ForegroundColor Green
}

# Force password change on first login
$ForcePass = Read-Host "Force password change on first login? (y/n)"
if ($ForcePass -eq "y" -or $ForcePass -eq "Y") {
    Set-LocalUser -Name $Username -PasswordRequired $true
    net user $Username /logonpasswordchg:yes | Out-Null
    Write-Host "✅ User will be required to change password on first login." -ForegroundColor Green
}

Write-Host ""
Write-Host "-------------------------------------" -ForegroundColor Cyan
Write-Host "Username : $Username"
Write-Host "Full Name: $Fullname"
Write-Host "Home Dir : C:\Users\$Username"
Write-Host "-------------------------------------" -ForegroundColor Cyan
