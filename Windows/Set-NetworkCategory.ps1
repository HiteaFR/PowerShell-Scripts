#Droits admin nécessaire

#Afficher le profil actif
$ProfileName = Get-NetConnectionProfile

# Changer la catégorie du profil actif (valeurs acceptées : Public, Private, DomainAuthenticated)
Set-NetConnectionProfile -Name $ProfileName.Name -NetworkCategory Private

#Changer toutes sur toutes les connexions
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private