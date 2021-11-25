[securestring]$Password = ConvertTo-SecureString 'Password' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential("User", $Password)

$Hosts = @("Server")

foreach ($Server in $Hosts) {
    
    Test-Connection -ComputerName $Server -Count 3

    Test-WSMan -ComputerName $Server -Credential $Credential -Authentication default

}