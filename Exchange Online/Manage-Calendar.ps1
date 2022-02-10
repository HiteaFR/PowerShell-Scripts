$Compte = Read-Host "Choisir un compte (user@domaine.fr)"
$Action = Read-Host "V pour voir ou M pour voir et modifier"
# $Excluded = Read-Host "Compte Exclus séparé par des virgules"
# Where-Object Identity -notlike "*Meeting4Display*" | Where-Object Identity -notlike "*notification*"
$Excluded = @('*Meeting4Display*', '*notification*')

$AuditMailboxe = Get-Mailbox -Identity $Compte
$Mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object RecipientTypeDetails -eq "UserMailbox" | Where-Object { $Excluded -notcontains $_.Identity }

foreach ($Bal in $Mailboxes) {

    if ($BAL.Languages -like "*FR*") {
        $Calendar = Get-MailboxFolderPermission -Identity "$($BAL.PrimarySMTPAddress):\Calendrier" -ErrorAction SilentlyContinue | Select Identity, User, AccessRights
    }
    else {
        $Calendar = Get-MailboxFolderPermission -Identity "$($BAL.PrimarySMTPAddress):\Calendar" -ErrorAction SilentlyContinue | Select Identity, User, AccessRights
    }

    if ($Calendar.User.DisplayName -notcontains $AuditMailboxe.Identity) {
        Write-Host "$($AuditMailboxe.Identity) n'a pas acces au Calendrier de $($Bal.Identity)" -ForegroundColor Yellow
        if ($Action -eq "M") {

            if ($BAL.Languages -like "*FR*") {

                Add-MailboxFolderPermission -Identity ($Bal.Identity + ":\Calendrier") -User $AuditMailboxe.UserPrincipalName -AccessRights Reviewer

            }
            else {

                Add-MailboxFolderPermission -Identity ($Bal.Identity + ":\Calendar") -User $AuditMailboxe.UserPrincipalName -AccessRights Reviewer
            
            }
        }
    }
    else {
        Write-Host "$($AuditMailboxe.Identity) a acces au Calendrier de $($Bal.Identity)" -ForegroundColor Green
    }

}