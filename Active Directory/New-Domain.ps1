#Installer la fonctionnalité AD DS
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

#Importer le module de déploiement
Import-Module ADDSDeployment

#Créer une nouvelle forêt
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName "DOMAINE.LOCAL" `
    -DomainNetbiosName "DOMAINE" `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true

#Voir les rédirecteurs du serveur DNS
Get-DnsServerForwarder

#Ajouter un redirecteur au serveur DNS, Exemple avec le DNS de CloudFare
Add-DnsServerForwarder -IPAddress 1.1.1.1