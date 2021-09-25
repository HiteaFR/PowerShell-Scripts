$License = 'hitea:STANDARDPACK'
$EnabledPlans = @(
    'TEAMS1'
    'WHITEBOARD_PLAN1'
)
$Exclusions = @(
    'Sync_ADCONNECT1@hitea.onmicrosoft.com'
)
$AllPlans = (Get-MsolAccountSku | Where-Object { $_.AccountSkuId -eq $License } | Select-Object -ExpandProperty ServiceStatus).ServicePlan.ServiceName
$DisabledPlans = $AllPlans | Where-Object { $EnabledPlans -notcontains $_ }
$E1CustomizedLicense = New-MsolLicenseOptions -AccountSkuId $License -DisabledPlans $DisabledPlans
$Users = Get-MsolUser -UnlicensedUsersOnly -All -EnabledFilter EnabledOnly
foreach ($User in $Users) {
    if ($User.UsageLocation -ne 'FR') {
        Set-MsolUser -UserPrincipalName $User.UserPrincipalName -UsageLocation PL
    }
    if ($User.IsLicensed -eq $false -and $Exclusions -notcontains $User.UserPrincipalName) {
        Set-MsolUserLicense -UserPrincipalName $User.UserPrincipalName -AddLicenses $License -LicenseOptions $E1CustomizedLicense
    }
}


$LicensePlans = Get-MsolAccountSku | ForEach-Object {
    [PSCustomObject] @{
        LicenseName = $_.AccountSkuId
        Plans       = $_.ServiceStatus.ServicePlan.ServiceName -join ', '
    }
}
$LicensePlans | Format-Table -AutoSize