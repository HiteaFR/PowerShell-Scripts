Import-Module Hyper-V

[securestring]$Password = ConvertTo-SecureString 'Password' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential("User", $Password)

$ReportsPath = (Join-Path $env:LOCALAPPDATA "Hitea\AmInf\Reports")
New-Item -Path $ReportsPath -ItemType Directory -Force | Out-Null

$VMhost = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
$Vms = Get-VM -VMName * 

$VMsDetail = $Vms | Select-Object Id, Name, State, OperationalStatus, Status,
@{Name = "MemoryStatus"; Expression = { $_.MemoryStatus } },
@{Name = "MemAssignMB"; Expression = { $_.MemoryAssigned / 1MB } },
@{Name = "PctAssignTotal"; Expression = { [math]::Round(($_.memoryAssigned / ($vmhost.TotalVisibleMemorySize * 1KB)) * 100, 2) } },
@{Name = "MemDemandMB"; Expression = { $_.MemoryDemand / 1MB } },
@{Name = "PctDemandTotal"; Expression = { [math]::Round(($_.memoryDemand / ($vmhost.TotalVisibleMemorySize * 1KB)) * 100, 2) } }
  
$ServerDetail = [pscustomobject]@{
    Computername         = $vmhost.CSName
    OperatingSystem      = $vmhost.Caption
    TotalMemory          = $vmhost.totalVisibleMemorySize / 1MB -as [int]
    FreeMemory           = [Math]::Round($vmhost.FreePhysicalMemory / 1MB, 2)
    PctMemoryFree        = [Math]::Round(($vmhost.FreePhysicalMemory / $vmhost.totalVisibleMemorySize) * 100, 2)
    TotalVirtualMemory   = $vmhost.totalVirtualMemorySize / 1MB -as [int]
    FreeVirtualMemory    = [Math]::Round($vmhost.FreeVirtualMemory / 1MB, 2)
    PctVirtualMemoryFree = [Math]::Round(($vmhost.FreeVirtualMemory / $vmhost.totalVirtualMemorySize) * 100, 2)
    RunningVMs           = $vms.count
    TotalAssignedMemory  = ($vms | Measure-Object -Property MemoryAssigned -sum).sum / 1GB 
    TotalDemandMemory    = ($vms | measure-object -Property MemoryDemand -sum).sum / 1GB 
    PctDemand            = [math]::Round(($vms.memorydemand | measure-object -sum).sum / ($vms.memoryassigned | measure-object -sum).sum * 100, 2)
    TotalMaximumMemory   = ($vms | Measure-Object -Property MemoryMaximum -sum).sum / 1GB
}

$ServerDetail | Export-Csv -Path (Join-Path $ReportsPath "$($VMhost.CSName)_Infos.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation

$VMsDetail | Export-Csv -Path (Join-Path $ReportsPath "$($VMhost.CSName)_VMs.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation

Get-EventLog -Logname System -After (Get-Date).AddHours(-24) | Where-Object { $_.EventID -in (6005, 6006, 6008, 6009, 1074, 1076) }

Foreach ($Item in $VMsDetail) {

    if ($Item.State -eq "Running") {

        Invoke-Command -VMId $Item.Id -Credential $Credential -ScriptBlock {

            $VMInfos = Get-CimInstance -ClassName Win32_OperatingSystem
            $Win32Apps = Get-WmiObject -Class Win32_Product
            $WinAppx = Get-AppxPackage

            Write-Host $VMInfos.CSName
            Write-Host $VMInfos.Caption
            $VMInfos | Format-List
            Get-WmiObject -Class Win32_Product | Format-Table
            $WinAppx | Format-Table

        } -ErrorAction Stop

    }
}

<#

Get-VM –Name * -Computername SRV01 | enable-vmresourcemetering

Measure-VM -name * -Computername SRV01

Get-VM  -VMName * -ComputerName SRV01 | Reset-VMResourceMetering

$VmsState = [enum]::GetNames([Microsoft.HyperV.Powershell.VMState])
$VmsStatus = [enum]::GetNames([Microsoft.HyperV.Powershell.VMOperationalStatus])

        try {
            Write-Host "Get infos of VM : $($Item.Name)"

        }
        catch {
            Write-Output "Get VM infos failed"
        }

#>