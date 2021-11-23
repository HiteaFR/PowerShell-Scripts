New-VM -Name $Args.VmName -Generation 2 -SwitchName $Args.SwitchName -Path $Args.VmPath -NewVHDPath $Args.VhdPath -NewVHDSizeBytes 127GB

New-VM -Name $Args.VmName -Generation 2 -SwitchName $Args.SwitchName -Path $Args.VmPath -VHDPath $Args.VhdPath

New-VM -Name $Args.VmName -Generation 2 -SwitchName $Args.SwitchName -Path $Args.VmPath -NoVHD

Set-VM -Name $Args.VmName -CheckpointType Production -AutomaticCheckpointsEnabled $false -AutomaticStartAction Start -AutomaticStopAction Shutdown -ProcessorCount $Args.VmProc -MemoryStartupBytes $Args.VmRam

Enable-VMIntegrationService -VMName $Args.VmName -Name "Interface de services d’invité"

Disable-VMIntegrationService -VMName $Args.VmName -Name "Interface de services d’invité"

New-VHD -Path $Args.VhdPath -SizeBytes $Args.VhdSize -Dynamic

Add-VMHardDiskDrive -VMName $Args.VmName -Path $Args.VhdPath

Set-VMFirmware $Args.VmName -EnableSecureBoot On -BootOrder ((Get-VMFirmware $Args.VmName).BootOrder[1]), ((Get-VMFirmware $Args.VmName).BootOrder[0])

Start-VM $Args.VmName
