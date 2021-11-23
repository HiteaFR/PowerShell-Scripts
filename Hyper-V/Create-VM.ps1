Import-Module Hyper-V

$HypervConfig = Get-VMHost | Select-Object VirtualHardDiskPath, VirtualMachinePath

Write-Host ""
Write-Host "Emlacement des VM: " $HypervConfig.VirtualMachinePath
Write-Host "Emplacement des VHD: " $HypervConfig.VirtualHardDiskPath
Write-Host ""

$NewConfig = Read-Host "Voulez-vous changer les emplacements ? (o pour oui, non par défaut) "

if ($NewConfig -eq "o") {

    $HvVmPath = Read-Host "Entre un chemin pour les VM (a pour annuler)"

    if (Test-Path $HvVmPath -ErrorAction SilentlyContinue) {
        Set-VMHost -VirtualMachinePath $HvVmPath
    }

    $HvVhdPath = Read-Host "Entre un chemin pour les VHD (a pour annuler)"

    if (Test-Path $HvVhdPath -ErrorAction SilentlyContinue) {
        Set-VMHost -VirtualHardDiskPath $HvVhdPath
    }

    $HypervConfig = Get-VMHost | Select-Object VirtualHardDiskPath, VirtualMachinePath

    Write-Host ""
    Write-Host "Emlacement des VM: " $HypervConfig.VirtualMachinePath
    Write-Host "Emplacement des VHD: " $HypervConfig.VirtualHardDiskPath
    Write-Host ""

}

$Template = Read-Host "Avez-vous un template VHD pour votre VM ? (o pour oui, non par défaut) "

if ($Template -eq "o") {
    do {

        $TemplatePath = Read-Host "Entre un chemin pour le VHD (a pour annuler)"

        if ($TemplatePath -eq "a") {
            break
        }

    } until (Test-Path $TemplatePath -ErrorAction SilentlyContinue)

}

$VMName = Read-Host "Entrez un Nom pour votre VM"
$VMSwitch = Read-Host "Entrez un le nom du swith pour votre VM"
New-Item -Path (Join-Path $HypervConfig.VirtualMachinePath ($VMName + "\Virtual Hard Disks")) -ItemType Directory -Force
$VhdPath = (Join-Path $HypervConfig.VirtualMachinePath ($VMName + "\Virtual Hard Disks"))

if (!(Test-Path $TemplatePath -ErrorAction SilentlyContinue)) {
    $VhdSize = Read-Host "Entrez la capacité pour le VHDx (avec Gb à la fin)"
    $VhdFile = $VMName + ".vhdx"
    New-VM -Name $VMName -Generation 2 -SwitchName $VMSwitch -Path $HypervConfig.VirtualMachinePath -NewVHDPath (Join-Path $VhdPath $VhdFile) -NewVHDSizeBytes ($VhdSize)
}
elseif (Test-Path $TemplatePath -ErrorAction SilentlyContinue) {
    Start-BitsTransfer -Source $TemplatePath -Destination $VhdPath
    $VhdFile = Split-Path $TemplatePath -leaf
    New-VM -Name $VMName -Generation 2 -SwitchName $VMSwitch -Path $HypervConfig.VirtualMachinePath -VHDPath (Join-Path $VhdPath $VhdFile)
}
else {
    New-VM -Name $VMName -Generation 2 -SwitchName $VMSwitch -Path $HypervConfig.VirtualMachinePath -NoVHD
}

$VMProc = Read-Host "Entrez le nombre de processeurs pour votre VM"
$VMRam = Read-Host "Entrez la RAM pour votre VM (avec Gb à la fin) "

Set-VM -Name $VMName -CheckpointType Production -AutomaticCheckpointsEnabled $false -AutomaticStartAction Start -AutomaticStopAction Shutdown -ProcessorCount $VMProc -MemoryStartupBytes ($VMRam)
Set-VMFirmware $VMName -EnableSecureBoot On -BootOrder ((Get-VMFirmware $VMName).BootOrder[1]), ((Get-VMFirmware $VMName).BootOrder[0])

Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface"

$VMDC = Read-Host "Est-ce que votre VM est un controlleur de domaine ? (o pour oui, non par défaut) "
if ($VMDC -eq "o") {
    Disable-VMIntegrationService -VMName $VMName -Name "Time Synchronization"
}

$VMHdd = Read-Host "Est-ce que vous souhaitez ajouter un autre VHD à la VM ? (o pour oui, non par défaut) "
if ($VMHdd -eq "o") {

    $VhdName = Read-Host "Entrez un nom pour le VHDx (avec .vhdx)"
    $VhdSize = Read-Host "Entrez la capacité pour le VHDx (en Gb)"

    New-VHD -Path (Join-Path $VhdPath $VhdName) -SizeBytes $VhdSize -Dynamic

    Add-VMHardDiskDrive -VMName $VMName -Path (Join-Path $VhdPath $VhdName)
}

$VMOs = Read-Host "Quel est l'OS de votre VM (l pour linux, Windows par défaut) "

switch ($VMOs) {
    "l" { 

    }
    Default {
        
    }
}

$StartVM = Read-Host "Voulez-Vous démarrer la VM ? (o pour oui, non par défaut) "

if ($StartVM -eq "o") {
    Start-VM $VMName
}