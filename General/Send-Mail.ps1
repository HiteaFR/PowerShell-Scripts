# Get the credential
$creduser = Read-Host "Sender Email"
$credpassword = Read-Host "Sender Password"

[securestring]$secStringPassword = ConvertTo-SecureString $credpassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($creduser, $secStringPassword)

$Users = Import-Csv -Path "Send-Mail.csv" -Delimiter ";" -Encoding UTF8

foreach ($User in $Users) {

    ## Define the Send-MailMessage parameters
    $mailParams = @{
        SmtpServer                 = 'smtp.office365.com'
        Port                       = '587'
        UseSSL                     = $true
        Credential                 = $credObject
        From                       = $creduser
        To                         = $($User.UserMail)
        Subject                    = "Mail from PowerShell"
        Body                       = "Hello,<br><br>
        Your email is $($User.UserMail)<br>"
        DeliveryNotificationOption = 'OnFailure'
        BodyAsHtml                 = $true
        Encoding                   = [System.Text.Encoding]::UTF8
    }

    ## Send the message
    Send-MailMessage @mailParams

}