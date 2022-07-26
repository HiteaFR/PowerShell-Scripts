<#
.SYNOPSIS
    List all workstations in the domain.  Fields include LastLogonDate and the latest BitLocker password set date (if present)
.DESCRIPTION
    List all workstations in the domain.  Fields include LastLogonDate and the latest BitLocker password set date (if present)
.PARAMETER SearchBase
    OU where the script will begin it's search
.INPUTS
    None
.OUTPUTS
    CSV in script path
.EXAMPLE
    .\Get-BitlockerStatus.ps1 -SearchBase ""
.NOTES

#>

[CmdletBinding()]
Param (
    [string]$SearchBase = "OU=..."
)

Try { Import-Module ActiveDirectory -ErrorAction Stop }
Catch { Write-Warning "Unable to load Active Directory module because $($Error[0])"; Exit }


Write-Verbose "Getting Workstations..." -Verbose
$Computers = Get-ADComputer -Filter * -SearchBase $SearchBase -Properties LastLogonDate
$Count = 1
$Results = ForEach ($Computer in $Computers) {
    Write-Progress -Id 0 -Activity "Searching Computers for BitLocker" -Status "$Count of $($Computers.Count)" -PercentComplete (($Count / $Computers.Count) * 100)
    New-Object PSObject -Property @{
        ComputerName         = $Computer.Name
        LastLogonDate        = $Computer.LastLogonDate 
        BitLockerPasswordSet = Get-ADObject -Filter "objectClass -eq 'msFVE-RecoveryInformation'" -SearchBase $Computer.distinguishedName -Properties msFVE-RecoveryPassword, whenCreated | Sort-Object whenCreated -Descending | Select-Object -First 1 | Select-Object -ExpandProperty whenCreated
    }
    $Count ++
}
Write-Progress -Id 0 -Activity " " -Status " " -Completed

$ReportPath = Join-Path (Split-Path $MyInvocation.MyCommand.Path) -ChildPath "Get-BitlockerStatus.csv"
Write-Verbose "Building the report..." -Verbose
$Results | Select-Object ComputerName, LastLogonDate, BitLockerPasswordSet | Sort-Object ComputerName | Export-Csv $ReportPath -NoTypeInformation -Delimiter ";" -Encoding UTF8
Write-Verbose "Report saved at: $ReportPath" -Verbose