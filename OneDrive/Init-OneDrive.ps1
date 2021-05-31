#Récupérer la liste de utilisateurs depuis un fichier
$users = Get-Content -path "C:\Users.txt"

#Récupérer tous les utilsiateurs
$users = Get-MsolUser -All | Where-Object { $_.islicensed -eq $true }

#Provisionner OneDrive pour les utilisateurs (limite de 100 environ)
Request-SPOPersonalSite -UserEmails $users

#Pour un plus grand nombre d'utilisateurs
#https://docs.microsoft.com/fr-fr/onedrive/pre-provision-accounts