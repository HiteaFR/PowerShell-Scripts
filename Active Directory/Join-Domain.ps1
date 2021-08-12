# Parametres Domaine
$domain = "DOMAIN"

# Le nom d'utilisateur
$username = "$domain\USERNAME HERE"

# Le mot de passe de l'utilisateur
$password = "PASSWORD HERE" | ConvertTo-SecureString -asPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential($username, $password)

Add-Computer -DomainName $domain -Credential $credential