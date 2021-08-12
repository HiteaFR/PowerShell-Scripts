# Importer le fichier CSV
$users = Import-csv "Templates\Import-MsolUsers.csv" -Delimiter ";" -Encoding UTF8

# Get-MsolAccountSku

# Renseigner le SKU de la licence
$accountSkuId = "reseller-account:O365_BUSINESS_PREMIUM"

# Renseigner les options déactivées
# Get-MsolAccountSku | select -ExpandProperty ServiceStatus
$BannedList = @("MICROSOFTBOOKINGS", "KAIZALA_O365_P2", "Deskless", "PROJECTWORKMANAGEMENT", "POWERAPPS_O365_P1", "DYN365BC_MS_INVOICING", "O365_SB_Relationship_Management", "STREAM_O365_SMB", "SWAY", "YAMMER_ENTERPRISE")

$licenseOptions = New-MsolLicenseOptions -AccountSkuId $accountSkuId -DisabledPlans $BannedList

# Définir les licences pour les utilisateurs
ForEach ($user in $users) {

    $upn = $user.Username

    Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $accountSkuId

    Start-Sleep -Seconds 2

    Set-MsolUserLicense -UserPrincipalName $upn -LicenseOptions $licenseOptions

}