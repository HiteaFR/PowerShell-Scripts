[securestring]$Password = ConvertTo-SecureString 'Password' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential("User", $Password)

$Hosts = @("Server")

$webhook = "WebHook URI"

$Date = (Get-Date).AddHours(-24)

$Events = Invoke-Command -ComputerName $Hosts -Credential $Credential -ScriptBlock {

Get-EventLog -Logname System -After $using:Date | Where {$_.EventID -in (6005,6006,6008,6009,1074,1076)}

} | Sort-Object -Property PSComputerName

if ($Events) {

$body = @{
    "@type"    = "MessageCard"
    "@context" = "<http://schema.org/extensions>"
    "title"    = 'Rapport de redémarrage serveur'
    "themeColor" = 'ff0000'
    "text"     = "Serveur Crash"
    "sections" = @(
      @{
        "activityTitle"    = 'Logs'
        "activityText"     =  $($Events.Message)
      }
    )
  } | ConvertTo-JSON

Invoke-RestMethod -Method post -ContentType 'application/json; charset=utf-8' -Body $body -Uri $webhook

}