$Compte = Read-Host "Choisir un compte (user@domaine.fr)"
$Action = Read-Host "V pour voir ou M pour voir et modifier"
# $Excluded = Read-Host "Compte Exclus séparé par des virgules"

$AuditMailboxe = Get-Mailbox -Identity $Compte
$Mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object RecipientTypeDetails -eq "UserMailbox"

foreach ($Bal in $Mailboxes) {

    if ($BAL.Languages -like "*FR*") {
        $Calendar = Get-MailboxFolderPermission -Identity "$($BAL.PrimarySMTPAddress):\Calendrier" -ErrorAction SilentlyContinue | Select-Object Identity, User, AccessRights
    }
    else {
        $Calendar = Get-MailboxFolderPermission -Identity "$($BAL.PrimarySMTPAddress):\Calendar" -ErrorAction SilentlyContinue | Select-Object Identity, User, AccessRights
    }

    if ($Calendar.User.DisplayName -notcontains $AuditMailboxe.DisplayName) {
        Write-Host "$($AuditMailboxe.DisplayName) n'a pas acces au Calendrier de $($Bal.DisplayName)" -ForegroundColor Red
        if ($Action -eq "M") {

            if ($BAL.Languages -like "*FR*") {

                Add-MailboxFolderPermission -Identity ($Bal.Identity + ":\Calendrier") -User $AuditMailboxe.UserPrincipalName -AccessRights Editor

            }
            else {

                Add-MailboxFolderPermission -Identity ($Bal.Identity + ":\Calendar") -User $AuditMailboxe.UserPrincipalName -AccessRights Editor
            
            }
            Write-Host "$($AuditMailboxe.DisplayName) a acces au Calendrier de $($Bal.DisplayName) en écriture" -ForegroundColor Green
        }
        elseif ($Action -eq "V") {

            if ($BAL.Languages -like "*FR*") {

                Add-MailboxFolderPermission -Identity ($Bal.Identity + ":\Calendrier") -User $AuditMailboxe.UserPrincipalName -AccessRights Reviewer

            }
            else {

                Add-MailboxFolderPermission -Identity ($Bal.Identity + ":\Calendar") -User $AuditMailboxe.UserPrincipalName -AccessRights Reviewer
            
            }

            Write-Host "$($AuditMailboxe.DisplayName) a acces au Calendrier de $($Bal.DisplayName) en lecture" -ForegroundColor Green
        }
    }
    else {
        $Calendar | foreach { if ($_.User.DisplayName -eq $AuditMailboxe.DisplayName) { Write-Host "$($AuditMailboxe.DisplayName) a acces au Calendrier de $($Bal.DisplayName) en $($_.AccessRights)" -ForegroundColor Green }
        }
    }

}