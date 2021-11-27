[securestring]$Password = ConvertTo-SecureString 'Password' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential(".\Admin", $Password)

$ReportsPath = (Join-Path $env:LOCALAPPDATA "Hitea\AmInf\Reports")
New-Item -Path $ReportsPath -ItemType Directory -Force | Out-Null

$VMhost = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop

$TestHostReports = Get-ChildItem -Path (Join-Path $ReportsPath "$($VMhost.CSName)_*.csv")

Write-Host ""
Write-Host "Export reports path: $ReportsPath"
Write-Host ""
Write-Host "Get infos of Host : $($vmhost.CSName)"
Write-Host ""

if (!$TestHostReports) {

    $RestartEvents = Get-EventLog -Logname System -After (Get-Date).AddHours(-24) | Where-Object { $_.EventID -in (6005, 6006, 6008, 6009, 1074, 1076) }
    $Win32Apps = Get-WmiObject -Class Win32_Product
    $WinAppx = Get-AppxPackage

    $ServerDetail = [pscustomobject]@{
        Computername         = $vmhost.CSName
        OperatingSystem      = $vmhost.Caption
        TotalMemory          = $vmhost.totalVisibleMemorySize / 1MB -as [int]
        FreeMemory           = [Math]::Round($vmhost.FreePhysicalMemory / 1MB, 2)
        PctMemoryFree        = [Math]::Round(($vmhost.FreePhysicalMemory / $vmhost.totalVisibleMemorySize) * 100, 2)
        TotalVirtualMemory   = $vmhost.totalVirtualMemorySize / 1MB -as [int]
        FreeVirtualMemory    = [Math]::Round($vmhost.FreeVirtualMemory / 1MB, 2)
        PctVirtualMemoryFree = [Math]::Round(($vmhost.FreeVirtualMemory / $vmhost.totalVirtualMemorySize) * 100, 2)
    }

    $ServerDetail | Export-Csv -Path (Join-Path $ReportsPath "$($VMhost.CSName)_Infos.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation
    $RestartEvents | Export-Csv -Path (Join-Path $ReportsPath "$($VMhost.CSName)_Restart_Events.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation
    $WinAppx | Export-Csv -Path (Join-Path $ReportsPath "$($VMhost.CSName)_AppxPackages.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation
    $Win32Apps | Export-Csv -Path (Join-Path $ReportsPath "$($VMhost.CSName)_Msis.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation
}

Write-Host "Detect HyperV Service"
Write-Host ""

$HyperV = Get-Service HvHost -ErrorAction SilentlyContinue

If ($HyperV.Status -eq "Running") {

    try {
        Import-Module Hyper-V

        $VmsState = [enum]::GetNames([Microsoft.HyperV.Powershell.VMState])
        $VmsStatus = [enum]::GetNames([Microsoft.HyperV.Powershell.VMOperationalStatus])
        $Vms = Get-VM -VMName *

        $Vms | Select-Object Id, Name, State, OperationalStatus, Status, Networkadapters,
        @{Name = "MemoryStatus"; Expression = { $_.MemoryStatus } },
        @{Name = "MemAssignMB"; Expression = { $_.MemoryAssigned / 1MB } },
        @{Name = "PctAssignTotal"; Expression = { [math]::Round(($_.memoryAssigned / ($vmhost.TotalVisibleMemorySize * 1KB)) * 100, 2) } },
        @{Name = "MemDemandMB"; Expression = { $_.MemoryDemand / 1MB } },
        @{Name = "PctDemandTotal"; Expression = { [math]::Round(($_.memoryDemand / ($vmhost.TotalVisibleMemorySize * 1KB)) * 100, 2) } } | Export-Csv -Path (Join-Path $ReportsPath "$($VMhost.CSName)_VMs.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation

        Foreach ($Item in $Vms) {

            if ($Item.State -eq "Running") {
                try {
                    Write-Host "Get infos of VM : $($Item.Name)"
                    Write-Host ""
                    
                    $VmInfos = Invoke-Command -VMId $Item.Id -Credential $Credential -ScriptBlock { Get-CimInstance -ClassName Win32_OperatingSystem }
                    $VMNetwork = ($Item | Select-Object -ExpandProperty Networkadapters | Select-Object IPAddresses)
                    $VmInfos | Add-Member -NotePropertyName IPAddresses -NotePropertyValue $VMNetwork

                    $VmEvents = Invoke-Command -VMId $Item.Id -Credential $Credential -ScriptBlock { Get-EventLog -Logname System -After (Get-Date).AddHours(-24) | Where-Object { $_.EventID -in (6005, 6006, 6008, 6009, 1074, 1076) } }

                    $VmInfos | Export-Csv -Path (Join-Path $ReportsPath "$($VMhost.CSName)_$($Item.Name)_Infos.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation
                    $VmEvents | Export-Csv -Path (Join-Path $ReportsPath "$($VMhost.CSName)_$($Item.Name)_Events.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation
                }
                catch {
                    Write-Output "Get VM infos failed"
                }
            }
            
        }

    }
    catch {
        
    }

}