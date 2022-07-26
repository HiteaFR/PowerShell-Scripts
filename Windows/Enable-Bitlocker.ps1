# Bitlocker avec TPM
if ((Get-BitLockerVolume -MountPoint $env:SystemDrive).VolumeStatus -eq "FullyDecrypted") {

    Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -TpmProtector
    Enable-BitLocker -MountPoint $env:SystemDrive -RecoveryPasswordProtector -SkipHardwareTest

}

#Bitlocker avec mot de passe
if ((Get-BitLockerVolume -MountPoint $env:SystemDrive).VolumeStatus -eq "FullyDecrypted") {

    $BitLockerPwd = ConvertTo-SecureString "Password" -AsPlainText -Force
    Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -PasswordProtector -Password $BitLockerPwd
    Enable-BitLocker -MountPoint $env:SystemDrive -RecoveryPasswordProtector -SkipHardwareTest

}