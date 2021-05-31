#Définir l'adresse Webhook du canal Teams
$webhook = ""

#Créer le message
$body = ConvertTo-Json -depth 3 @{
    summary    = 'Message Teams'
    themeColor = '0055DD'
    sections   = @(
        @{
            activityTitle = "Titre du message `n"
            activityText  = "Ceci est un message généré en PowerShell"
        }
    )
}

#Envoyer le message sur Teams
Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $body -Uri $webhook