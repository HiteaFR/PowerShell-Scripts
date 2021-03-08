#Commande basique
net use L: UNC_DU_PARTAGE /PERSISTENT:NO /user:USER PASSWORD

##Créer un lecteur avec PowerShell

##Créer un objet Credential avec nom d'utilisateur et mot de passe
$Credential = New-Object System.Management.Automation.PsCredential("USER", (ConvertTo-SecureString -String "PASSWORD" -AsPlainText -Force))

##Créer le lecteur PowerShell non persistent
New-PSDrive -Name "NOM_DU_LECTEUR" -Root "UNC_DU_PARTAGE" -PSProvider "FileSystem" -Credential $Credential

##Créer le lecteur PowerShell persistent
New-PSDrive -Name "NOM_DU_LECTEUR" -Root "UNC_DU_PARTAGE" -PSProvider "FileSystem" -Credential $Credential -Persist