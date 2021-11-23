Import-Module Hyper-V

[securestring]$Password = ConvertTo-SecureString 'Password' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential("User", $Password)

$Hosts = @("Server")

$Path = ("Path.csv")

$VmsState = [enum]::GetNames([Microsoft.HyperV.Powershell.VMState])

$VmsStatus = [enum]::GetNames([Microsoft.HyperV.Powershell.VMOperationalStatus])

$VM = Invoke-Command -ComputerName $Hosts -Credential $Credential -ScriptBlock { Get-VM -VMName * } | Sort-Object -Property PSComputerName

$VM | Select-Object PSComputerName, Name, State, OperationalStatus, Status | Export-Csv -Path $Path -Encoding UTF8 -Delimiter ";" -NoTypeInformation


<#

 Write-Verbose "[Starting] $($MyInvocation.Mycommand)"
     
    Try {
     
        Write-Verbose "[Status] Getting Operating system information from $Computername"
        $vmhost = Get-CimInstance -computername $Computername -ClassName Win32_OperatingSystem -ErrorAction Stop
     
        Write-Verbose "[Status] Getting running virtual machines"
        $vms = Get-VM -Computername $Computername -ErrorAction Stop | where {$_.state -eq 'running'}
    }
    Catch {
        Throw $_
        #bail out
        Return
    }
     
    Write-Verbose "[Status] Analyzing..."
    $vmusage = $vms | select Name,
    @{Name = "Status";Expression={$_.MemoryStatus}},
    @{Name = "MemAssignMB";Expression={$_.MemoryAssigned/1MB}},
    @{Name = "PctAssignTotal";Expression={[math]::Round(($_.memoryAssigned/($vmhost.TotalVisibleMemorySize*1KB))*100,2)}},
    @{Name = "MemDemandMB";Expression={$_.MemoryDemand/1MB}},
    @{Name = "PctDemandTotal";Expression={[math]::Round(($_.memoryDemand/($vmhost.TotalVisibleMemorySize*1KB))*100,2)}}
     
    [pscustomobject]@{
        Computername         = $vmhost.CSName
        OperatingSystem      = $vmhost.Caption
        TotalMemory          = $vmhost.totalVisibleMemorySize/1MB -as [int]
        FreeMemory           = [Math]::Round($vmhost.FreePhysicalMemory/1MB,2)
        PctMemoryFree        = [Math]::Round(($vmhost.FreePhysicalMemory/$vmhost.totalVisibleMemorySize) *100,2)
        TotalVirtualMemory   = $vmhost.totalVirtualMemorySize/1MB -as [int]
        FreeVirtualMemory    = [Math]::Round($vmhost.FreeVirtualMemory/1MB,2)
        PctVirtualMemoryFree = [Math]::Round(($vmhost.FreeVirtualMemory/$vmhost.totalVirtualMemorySize) *100,2)
        RunningVMs           = $vms.count
        TotalAssignedMemory  = ($vms | Measure-Object -Property MemoryAssigned -sum).sum/1GB 
        TotalDemandMemory    = ($vms | measure-object -Property MemoryDemand -sum).sum/1GB 
        PctDemand            = [math]::Round(($vms.memorydemand | measure-object -sum).sum/($vms.memoryassigned | measure-object -sum).sum * 100,2)
        TotalMaximumMemory   = ($vms | Measure-Object -Property MemoryMaximum -sum).sum/1GB 
        VMs                  = $vmusage
    }
     
    Write-Verbose "[Ending] $($MyInvocation.Mycommand)"



Get-VM –Name * -Computername SRV01 | enable-vmresourcemetering

Measure-VM -name * -Computername SRV01

Get-VM  -VMName * -ComputerName SRV01 | Reset-VMResourceMetering


$VM_List = Get-VM | Select-Object Name, State, Id
$Host_List = $env:computername

$UpdateCollection = @()
Foreach ($vm in $VM_List)
{
$Computer_Name = $vm.Name
$Computer_Id = $vm.Id

if ($vm.State -eq "Running") {

    Write-Host "Get Name of VM $Computer_Id"
    try {
        $remoteComputerName = Invoke-Command -VMId $vm.Id -Credential $cred -ScriptBlock { $env:computername } -ErrorAction Stop
        Write-Output $remoteComputerName
        Invoke-Command -VMId $vm.Id -Credential $cred -ScriptBlock { 
            $objSession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$Computer))
            $objSearcher = $objSession.CreateUpdateSearcher()
         } -ErrorAction Stop  
    }
    catch {
        Write-Output "Fail"
    }
    
}
}


#>