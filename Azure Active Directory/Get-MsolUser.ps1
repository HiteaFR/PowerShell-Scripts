# Demande un nom d'utilisateur
$User = read-host -Prompt "User Name"

# Obtenir les infos de l'utilisateur
$user_dn = (get-mailbox $user).distinguishedname

# Liste des liste de distribution
"User " + $User + " is a member of the following groups:"
foreach ($group in get-distributiongroup -resultsize unlimited) {
    if ((get-distributiongroupmember $group.identity | select -expand distinguishedname) -contains $user_dn) { $group.name }
 
}