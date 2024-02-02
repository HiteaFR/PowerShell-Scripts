# Importer le module compatible Windows PowerShell si vous utilisez Powershell 7
Import-Module Msonline -UseWindowsPowerShell

# Connexion au module
Connect-MsolService

# Install SharePoint Module
Install-Module -Name Microsoft.Online.SharePoint.PowerShell

# Importer le module compatible Windows PowerShell si vous utilisez Powershell 7
Import-module Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell

# Connexion au module SpOnline
Connect-SpoService -Url "Admin URL"

# Récupérer la liste de utilisateurs depuis un fichier
# OU Récupérer tous les utilsiateurs
$users = Get-Content -path "C:\Users.txt"
$users = Get-MsolUser -All | Where-Object { $_.islicensed -eq $true }

# Provisionner OneDrive pour les utilisateurs (limite de 100 environ)
# Ou en bouclant par exemple
Request-SPOPersonalSite -UserEmails $users
$users | foreach { Request-SPOPersonalSite -UserEmails $_.UserPrincipalName }

# Pour un plus grand nombre d'utilisateurs
# https://docs.microsoft.com/fr-fr/onedrive/pre-provision-accounts