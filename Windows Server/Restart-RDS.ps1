
$ServerBroker = "Broker Name"
$ServerHostList = @("RDS Name", "RDS Name", "RDS Name")
$webhook = "Teams WebHook URL"

$TempLocalPath = "$env:Temp"
$LogTempFile = $TempLocalPath + "\" + ($ServerBroker) + "_" + (Get-Date -UFormat "%d-%m-%Y") + ".log"
$LogFolder = "C:\Logs"

$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol

#Reprise d'un fonction de log
Function Write-Log {
  param (
    [Parameter(Mandatory = $True)]
    [string]$LogOutput,
    [Parameter(Mandatory = $False)]
    [string]$LogPath = $LogTempFile
  )
  if (! (Test-Path $LogFolder)) {
    New-Item -Path $LogFolder -ItemType Directory
  }
  $currentDate = (Get-Date -UFormat "%d-%m-%Y")
  $currentTime = (Get-Date -UFormat "%T")
  "[$currentDate $currentTime] $logOutput" | Out-File $LogPath -Append
}

Write-Log -LogOutput ("Heure de début $(Get-Date -UFormat "%T")")

Foreach ($ServerHost in $ServerHostList) {

  Set-RDSessionHost -SessionHost $ServerHost -NewConnectionAllowed NotUntilReboot -ConnectionBroker $ServerBroker

  #Récupérer les sessions activent sur l'hôte RDS
  $Sessions = Get-RDUserSession -ConnectionBroker $ServerBroker | Where-Object HostServer -eq $ServerHost

  #Parcourir les sessions activent pour les déconnecter avant le redémarrage
  foreach ($Session in $Sessions) {

    #Ecriture d'un événement Windows
    Write-EventLog -LogName "System" -Source "EventLog" -EventId 6013 -EntryType Information -Message "Session $($Session.UserName) fermée"

    Write-Log -LogOutput ("Session $($Session.UserName) fermée")

    #Déconnexion des sessions
    Invoke-RDUserLogoff -HostServer $ServerHost -UnifiedSessionID $Session.UnifiedSessionID -Force
  }

  try {
    #Redémarrge du serveur et attente de la connectivité WinRM pour validation
    Restart-Computer -ComputerName $ServerHost -Wait -For WinRM -Delay 30 -Timeout 3600
    Write-Log -LogOutput ("$ServerHost redémarré")
  }
  catch {
    Write-Log -LogOutput ("Erreur de redémarrage serveur: $ServerHost")
  }

}

Write-Log -LogOutput ("Heure de fin $(Get-Date -UFormat "%T")")

$Logcontent = Get-Content $LogTempFile

Copy-Item $LogTempFile -Destination $LogFolder

#Création du JSON pour la notification
$body = @{
  "@type"      = "MessageCard"
  "@context"   = "<http://schema.org/extensions>"
  "title"      = 'Rapport de redémarrage RDS'
  "themeColor" = '0055DD'
  "text"       = "Serveurs: " + ($ServerHostList | Out-String)
  "sections"   = @(
    @{
      "activityTitle"    = 'Logs'
      "activitySubtitle" = 'Chemin du fichier: ' + $LogFolder
      "activityText"     = $Logcontent
    }
  )
} | ConvertTo-JSON

#Envoi du message sur teams
Invoke-RestMethod -Method post -ContentType 'application/json; charset=utf-8' -Body $body -Uri $webhook