# Connexion Exchange Online
Connect-ExchangeOnline

# Définir les options de base comme la langue et le fuseau horaire

Get-Mailbox -ResultSize unlimited | Set-MailboxRegionalConfiguration -Language fr-FR -TimeZone "Romance Standard Time" -DateFormat "dd/MM/yyyy" -LocalizeDefaultFolderName:$true