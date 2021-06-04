#Corriger les problèmes d'ouverture de session très lente, écran noir, performance sur serveur et serveur RDS

#Recommandé
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy" -Name "DeleteUserAppContainersOnLogoff" -Value 1
Logoff

#Autre méthode, supprimer les clés de registre
Remove-Item “HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System”
New-Item “HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System”
Remove-Item “HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules”
New-Item “HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules”
Remove-Item “HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Notifications” -Recurse
New-Item “HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Notifications”