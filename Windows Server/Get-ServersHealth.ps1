Import-Module Hyper-V

[securestring]$Password = ConvertTo-SecureString 'Password' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential("User", $Password)

$Hosts = @("Server")

$Lenght = (Get-Date).AddHours(-24)

foreach ($Server in $Hosts) {
    
    Test-Connection -ComputerName $Server -Count 3

    Test-WSMan -ComputerName $Server -Credential $Credential -Authentication default

    Invoke-Command -ComputerName $Server -Credential $Credential -ScriptBlock { 

        Get-VM -VMName * 

    }

    Invoke-Command -ComputerName $Server -Credential $Credential -ScriptBlock {

        Get-EventLog -Logname System -After $using:Lenght | Where {$_.EventID -in (6005,6006,6008,6009,1074,1076)}
        
    }

}