#Forcer la deconnexion de l'agent
azcmagent disconnect --force-local-only

#Désintaller les applications Agent et Proxy AAD
Get-ChildItem -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall | `
    Get-ItemProperty | `
    Where-Object { $_.DisplayName -eq "Azure Connected Machine Agent" } | `
    ForEach-Object { MsiExec.exe /x "$($_.PsChildName)" /qn }

Get-ChildItem -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall | `
    Get-ItemProperty | `
    Where-Object { $_.DisplayName -eq "Microsoft Azure Active Directory Application Proxy Connector" } | `
    ForEach-Object { MsiExec.exe /x "$($_.PsChildName)" /qn }

Get-ChildItem -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall | `
    Get-ItemProperty | `
    Where-Object { $_.DisplayName -eq "Microsoft Azure AD Application Proxy Connector Updater" } | `
    ForEach-Object { MsiExec.exe /x "$($_.PsChildName)" /qn }