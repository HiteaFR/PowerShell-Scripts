$Computers = Get-ADComputer -filter * | Select-Object -ExpandProperty Name
# Get-ADComputer -Filter { OperatingSystem -NotLike '*Server*' } -Properties OperatingSystem

Foreach ($computer in $computers) {

    if (!(Test-Connection -Cn $computer -BufferSize 16 -Count 1 -ea 0 -quiet)) { 
        write-host "cannot reach $computer offline" -f red 
    }
    else {
        $outtbl = @()
        Try {
            $sr = Get-WmiObject win32_bios -ComputerName $Computer  -ErrorAction Stop 
            $Xr = Get-WmiObject –class Win32_processor -ComputerName $computer -ErrorAction Stop   
            $ld = get-adcomputer $computer -properties Name, Lastlogondate, operatingsystem, ipv4Address, enabled, description, DistinguishedName -ErrorAction Stop
            $r = "{0} GB" -f ((Get-WmiObject Win32_PhysicalMemory -ComputerName $computer | Measure-Object Capacity  -Sum).Sum / 1GB)
            $x = gwmi win32_computersystem -ComputerName $computer | Select-Object @{Name = "Type"; Expression = { if (($_.pcsystemtype -eq '2')  ) { 
                        'Laptop' 
                    }
                    Else {
                        'Desktop Or Other something else' 
                    } 
                }
            }, Manufacturer, @{Name = "Model"; Expression = { if (($_.model -eq "$null")  ) { 'Virtual' } Else { $_.model } } }, username -ErrorAction Stop
            $t = New-Object PSObject -Property @{
                serialnumber              = $sr.serialnumber
                computername              = $ld.name
                Ipaddress                 = $ld.ipv4Address
                Enabled                   = $ld.Enabled
                Description               = $ld.description
                Ou                        = $ld.DistinguishedName.split(',')[1].split('=')[1] 
                Type                      = $x.type
                Manufacturer              = $x.Manufacturer
                Model                     = $x.Model
                Ram                       = $R
                ProcessorName             = ($xr.name | Out-String).Trim()
                NumberOfCores             = ($xr.NumberOfCores | Out-String).Trim()
                NumberOfLogicalProcessors = ($xr.NumberOfLogicalProcessors | Out-String).Trim()
                Addresswidth              = ($xr.Addresswidth | Out-String).Trim()
                Operatingsystem           = $ld.operatingsystem
                Lastlogondate             = $ld.lastlogondate
                LoggedinUser              = $x.username
            }
            $outtbl += $t
        }
        catch [Exception] {
            "Error communicating with $computer, skipping to next"   
        }
        $outtbl | Select-Object Computername, enabled, description, ipAddress, Ou, Type, Serialnumber, Manufacturer, Model, Ram, ProcessorName, NumberOfCores, NumberOfLogicalProcessors, Addresswidth, Operatingsystem, loggedinuser, Lastlogondate
    }
}