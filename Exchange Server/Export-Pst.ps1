#Tester sur Exchange Server 2010

#Atribuer le rôle pour les exports
New-ManagementRoleAssignment –Role “Mailbox Import Export” –User AD\Administrator

#Exporter toutes les boites
$Export = Get-Mailbox

#Exporter un liste de BAL
$Export = Get-Content .\Mailbox.txt

#Lancer les exports vers un dossier partagé
$Export | % { $_ | New-MailboxExportRequest -FilePath "\\<server FQDN>\<shared folder name>\$($_.alias).pst" }

#Vérifier l'état des exports en cours
Get-MailboxExportRequest | Get-MailboxExportRequestStatistics

#Supprimer les export terminés
Get-MailboxExportRequest | where { $_.status -eq "Completed" } | Remove-MailboxExportRequest

#Augmenter le nombre d'erreurs acceptées
Get-MailboxExportRequest -Status Failed | Set-MailboxExportRequest -BadItemLimit 500

#Redémarrer les exports en erreur
Get-MailboxExportRequest -Status Failed | Resume-MailboxExportRequest

#Créer un rapport d'erreurs détaillé
Get-MailboxExportRequest -Status Failed | Get-MailboxExportRequestStatistics -IncludeReport | FL > C:\FILEPATH\report.txt