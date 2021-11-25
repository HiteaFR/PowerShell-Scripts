Import-Module Hyper-V

[securestring]$Password = ConvertTo-SecureString 'Password' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential("User", $Password)

$Hosts = @("Server")

$ReportsPath = (Join-Path $env:LOCALAPPDATA "Hitea\AmInf\Reports")
New-Item -Path $ReportsPath -ItemType Directory -Force | Out-Null

$VmsState = [enum]::GetNames([Microsoft.HyperV.Powershell.VMState])
$VmsStatus = [enum]::GetNames([Microsoft.HyperV.Powershell.VMOperationalStatus])

$VMhost = Get-CimInstance -computername $Computername -ClassName Win32_OperatingSystem -ErrorAction Stop

# $VM = Invoke-Command -ComputerName $Hosts -Credential $Credential -ScriptBlock { }
$VM = Get-VM -VMName *

$vmusage = $VM | Select-Object Name, State, OperationalStatus, Status,
@{Name = "MemoryStatus"; Expression = { $_.MemoryStatus } },
@{Name = "MemAssignMB"; Expression = { $_.MemoryAssigned / 1MB } },
@{Name = "PctAssignTotal"; Expression = { [math]::Round(($_.memoryAssigned / ($vmhost.TotalVisibleMemorySize * 1KB)) * 100, 2) } },
@{Name = "MemDemandMB"; Expression = { $_.MemoryDemand / 1MB } },
@{Name = "PctDemandTotal"; Expression = { [math]::Round(($_.memoryDemand / ($vmhost.TotalVisibleMemorySize * 1KB)) * 100, 2) } }
     
$Server = [pscustomobject]@{
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
    VMs                  = $vmusage
}

foreach ($Item in $Server.VMs) {
    $Item
}

$Server.VMs | Export-Csv -Path (Join-Path $ReportsPath "$($vmhost.CSName)_VMs.csv") -Encoding UTF8 -Delimiter ";" -NoTypeInformation

Foreach ($Item in $VM) {

    $Computer_Id = $Item.Id

    if ($Item.State -eq "Running") {

        Write-Host "Get Name of Item $Computer_Id"
        try {
            $remoteComputerName = Invoke-Command -VMId $Item.Id -Credential $Credential -ScriptBlock { $env:computername } -ErrorAction Stop
            Write-Output $remoteComputerName
            Invoke-Command -VMId $Item.Id -Credential $Credential -ScriptBlock { 

                $WinAppx = Get-AppPackage
                $WinAppx

                $Win32AppObj = Get-WmiObject -Class Win32_Product
                $Win32AppObj.properties

            } -ErrorAction Stop  
        }
        catch {
            Write-Output "Fail"
        }
    
    }
}

<#

PSComputerName         : Windows-10
RunspaceId             : 9d089916-1433-4b86-bf2f-ef6200202a84
Name                   : Microsoft.BingWeather
Publisher              : CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US
PublisherId            : 8wekyb3d8bbwe
Architecture           : X64
ResourceId             :
Version                : 4.25.20211.0
PackageFamilyName      : Microsoft.BingWeather_8wekyb3d8bbwe
PackageFullName        : Microsoft.BingWeather_4.25.20211.0_x64__8wekyb3d8bbwe
InstallLocation        : C:\Program Files\WindowsApps\Microsoft.BingWeather_4.25.20211.0_x64__8wekyb3d8bbwe
IsFramework            : False
PackageUserInformation : {}
IsResourcePackage      : False
IsBundle               : False
IsDevelopmentMode      : False
NonRemovable           : False
Dependencies           : { Microsoft.NET.Native.Framework.2.2_2.2.27405.0_x64__8wekyb3d8bbwe,
    Microsoft.NET.Native.Runtime.2.2_2.2.27328.0_x64__8wekyb3d8bbwe,
    Microsoft.Advertising.Xaml_10.1808.3.0_x64__8wekyb3d8bbwe,
    Microsoft.VCLibs.140.00_14.0.27323.0_x64__8wekyb3d8bbwe... }
IsPartiallyStaged      : False
SignatureKind          : Store
Status                 : Ok


PSComputerName : Windows-10
RunspaceId     : 9d089916-1433-4b86-bf2f-ef6200202a84
Name           : InstallState
Value          : 5
Type           : SInt16
IsLocal        : True
IsArray        : False
Origin         : Win32_Product
Qualifiers     : { System.Management.QualifierData }

PSComputerName : Windows-10
RunspaceId     : 9d089916-1433-4b86-bf2f-ef6200202a84
Name           : Language
Value          : 0
Type           : String
IsLocal        : True
IsArray        : False
Origin         : Win32_Product
Qualifiers     : { System.Management.QualifierData }


Get-VM –Name * -Computername SRV01 | enable-vmresourcemetering

Measure-VM -name * -Computername SRV01

Get-VM  -VMName * -ComputerName SRV01 | Reset-VMResourceMetering

#>