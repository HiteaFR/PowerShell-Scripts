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

#autre exemple de message card
$body = @{
    "@type"    = "MessageCard"
    "@context" = "<http://schema.org/extensions>"
    "title"    = 'Titre'
    "themeColor" = '0055DD'
    "text"     = "Description"
    "sections" = @(
      @{
        "activityTitle"    = 'Titre section'
        "activitySubtitle" = 'Sous titre'
        "activityText"     = 'Texte de la section'
      }
    )
  } | ConvertTo-JSON

#Envoyer le message sur Teams
Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $body -Uri $webhook