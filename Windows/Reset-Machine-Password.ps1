#Vérifier la relation d'aprobation avec le domaine
#En batch
netdom verify /Domain:domain.local /UserO:User /PasswordO:*

#En PowerShell
Test-ComputerSecureChannel -Server 'DC.domain.local'

#Réparer la relation d'aprobation avec le domaine
#En batch
netdom resetpwd /s:DC /ud:User /pd:*

#En PowerShell
Reset-ComputerMachinePassword -Server "DC.domain.local" -Credential (Get-Credential)

#Autre méthode en PowerShell
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)

#Sortir le PC du domaine
Remove-Computer -UnjoinDomaincredential (Get-Credential) -Restart -Force

#Remettre le PC dans le domaine
Add-Computer -DomainName domain.local -Credential (Get-Credential) -Restart -Force