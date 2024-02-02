$HvHost = "Host Name"

$VmList = @("VM Name")

$TempLocalPath = "$env:Temp"
$LogTempFile = $TempLocalPath + "\" + ($HvHost) + "_" + (Get-Date -UFormat "%d-%m-%Y") + ".log"
$LogFolder = "C:\Logs"

#Log Function
Function Write-Log {
    param (
        [Parameter(Mandatory = $True)]
        [string]$LogOutput,
        [Parameter(Mandatory = $False)]
        [string]$LogPath = $LogTempFile
    )
    if (! (Test-Path $LogFolder)) {
        New-Item -Path $LogFolder -ItemType Directory
    }
    $currentDate = (Get-Date -UFormat "%d-%m-%Y")
    $currentTime = (Get-Date -UFormat "%T")
    "[$currentDate $currentTime] $logOutput" | Out-File $LogPath -Append
}

Write-Log -LogOutput ("Heure de début $(Get-Date -UFormat "%T")")

foreach ($Srv in $VmList) {
    Stop-Computer -ComputerName $Srv -Force
    Write-Log -LogOutput ("$Srv éteint")
}

Write-Log -LogOutput ("$HvHost redémarré")

Write-Log -LogOutput ("Heure de fin $(Get-Date -UFormat "%T")")

Copy-Item $LogTempFile -Destination $LogFolder

Restart-Computer -Force