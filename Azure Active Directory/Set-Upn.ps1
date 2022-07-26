$creduser = Read-Host "Admin email"
$credpassword = Read-Host "Admin Password"

[securestring]$secStringPassword = ConvertTo-SecureString $credpassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($creduser, $secStringPassword)

$Users = Import-Csv -Path "Set-Upn.csv" -Delimiter ";" -Encoding UTF8

Connect-MsolService -Credential $credObject

foreach ($User in $Users) {

    Write-host "Changement de $($User.Upn) pour $($User.NewUpn)"

    Set-MsolUserPrincipalName -UserPrincipalName $($User.Upn) -NewUserPrincipalName $($User.NewUpn)

}