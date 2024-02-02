$Users = Import-Csv -Path "Import_TeamsNumbers.csv" -Delimiter ";" -Encoding UTF8

$PolicyName = "Policy Name"

$RoutingName = "Route Name"

foreach ($User in $Users) {

    Write-Host "Définition des stratégies et de la SDA pour: $($User.Nom)"

    Grant-CsTeamsCallingPolicy -identity $User.Upn -PolicyName $PolicyName

    Grant-CsOnlineVoiceRoutingPolicy -Identity $User.Upn -PolicyName $RoutingName

    #Ancienne version du module version 2
    #Set-CsUser -Identity $User.Upn -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:$($User.Sda)

    #Module Teams version 4+
    Set-CsPhoneNumberAssignment -Identity $User.Upn -PhoneNumber $($User.Sda) -PhoneNumberType DirectRouting

    Set-CsPhoneNumberAssignment -Identity $User.Upn -EnterpriseVoiceEnabled $true
}

Write-Host "Attente de 90 secondes puis affichage de la liste des utilisateurs avec une SDA"

Start-Sleep -Seconds 90

$TeamsPhonyUsers = Get-CsOnlineUser | Where-Object { $_.LineURI -notlike $null }

Write-Host "Total des Utilisateurs: $(($TeamsPhonyUsers).count)"

$TeamsPhonyUsers | Format-Table DisplayName, UserPrincipalName, LineURI

$TeamsPhonyUsers | Select-Object DisplayName, UserPrincipalName, LineUri, DialPlan, OnlineVoiceRoutingPolicy, TeamsCallingPolicy, EnterpriseVoiceEnabled | Export-Csv "Annuaire_Teams.csv" -Delimiter ";" -Encoding UTF8 -NoTypeInformation