$creduser = Read-Host "Admin email"
$credpassword = Read-Host "Admin Password"

[securestring]$secStringPassword = ConvertTo-SecureString $credpassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($creduser, $secStringPassword)

Connect-AzureAD -Credential $credObject

$Table = New-Object 'System.Collections.Generic.List[System.Object]'

$Groups = Get-AzureAdGroup -All $True | Where-Object { $_.MailEnabled -eq $false -and $_.SecurityEnabled -eq $true } | Sort-Object DisplayName

$obj1 = [PSCustomObject]@{
    'Name'  = 'Security Group'
    'Count' = $Groups.count
}

$obj1

Foreach ($Group in $Groups) {
    $Users = (Get-AzureADGroupMember -ObjectId $Group.ObjectID | Sort-Object DisplayName | Select-Object -ExpandProperty DisplayName) -join ", "
    $GName = $Group.DisplayName
	
    $hash = New-Object PSObject -property @{ Name = "$GName"; Members = "$Users" }
	
    $obj = [PSCustomObject]@{
        'Name'    = $GName
        'Members' = $users
    }
	
    $table.add($obj)
}

$table | Export-Csv -Path "Groupe-SharePoint.csv" -Delimiter ";" -Encoding UTF8 -NoTypeInformation