# Importer le fichier CSV
$users = Import-csv "Templates\Import-MsolUsers.csv" -Delimiter ";" -Encoding UTF8

# Get-MsolAccountSku

# Renseigner le SKU de la licence
$accountSkuId = "reseller-account:O365_BUSINESS_ESSENTIALS"

# Renseigner les options déactivées
$BannedList = @("EXCHANGE_S_STANDARD", "KAIZALA_O365_P2", "STREAM_O365_SMB", "POWERAPPS_O365_P1", "PROJECTWORKMANAGEMENT", "SWAY", "YAMMER_ENTERPRISE")

$licenseOptions = New-MsolLicenseOptions -AccountSkuId $accountSkuId -DisabledPlans $BannedList

# Définir les licences pour les utilisateurs
ForEach ($user in $users) {

    $upn = $user.UserPrincipalName

    Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $accountSkuId

    Start-Sleep -Seconds 2

    Set-MsolUserLicense -UserPrincipalName $upn -LicenseOptions $licenseOptions

}