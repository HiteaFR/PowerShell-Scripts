# Importer le module Exchange Online
Import-Module ExchangeOnlineManagement

#Store the data from ADUsers.csv in the $ADUsers variable
$Mailboxes = Import-csv "Templates\Import-SharedMailbox.csv" -Delimiter ";" -Encoding UTF8

#Loop through each row containing user details in the CSV file 
foreach ($Mailbox in $Mailboxes) {

    if ((Get-MsolUser -UserPrincipalName $Mailbox.username -ErrorAction SilentlyContinue)) {
        Write-Warning "A Shared Mailbox with UPN $($Mailbox.username) already exist in Azure Active Directory."
    }
    else {
        try {
            New-Mailbox -Shared -Name $Mailbox.Name -DisplayName $Mailbox.Name -Alias $Mailbox.Alias -PrimarySmtpAddress $Mailbox.username
            Write-Host "The Shared Mailbox $($Mailbox.Name) ($($Mailbox.username)) was created." -ForegroundColor Green
        }
        catch {
            Write-Error "The Shared Mailbox $($Mailbox.Name) ($($Mailbox.username)) was not created."
        }

        foreach ($Member in ($Mailbox.Members).split(",")) {
            try {
                Add-MailboxPermission $Mailbox.username -User $Member -AccessRights FullAccess -InheritanceType all
                Write-Host "$($Members) added to the Shared Mailbox $($Mailbox.username)."
            }
            catch {
                Write-Error "$($Members) not added to the Shared Mailbox $($Mailbox.username)."
            }
        }

    }
}