Import-Module Hyper-V

[securestring]$Password = ConvertTo-SecureString 'Password' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential("User", $Password)

$Hosts = @("Server")

$Path = ("Path.csv")

$VmsState = [enum]::GetNames([Microsoft.HyperV.Powershell.VMState])

$VmsStatus = [enum]::GetNames([Microsoft.HyperV.Powershell.VMOperationalStatus])

$VM = Invoke-Command -ComputerName $Hosts -Credential $Credential -ScriptBlock {Get-VM -VMName *} | Sort-Object -Property PSComputerName

$VM | Select-Object PSComputerName, Name, State, OperationalStatus, Status | Export-Csv -Path $Path -Encoding UTF8 -Delimiter ";" -NoTypeInformation