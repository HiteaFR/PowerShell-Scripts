# Import active directory module for running AD cmdlets
Import-Module MSOnline
  
#Store the data from ADUsers.csv in the $ADUsers variable
$AADUsers = Import-csv "Templates\Import-MsolUsers.csv" -Delimiter ";" -Encoding UTF8

#Loop through each row containing user details in the CSV file 
foreach ($User in $AADUsers) {

    $FullName = "$($User.firstname) $($User.lastname)"

    if ((Get-MsolUser -UserPrincipalName $User.username)) {
        Write-Warning "A user account with UPN $($User.username) already exist in Azure Active Directory."
    }
    elseif (([string]::IsNullOrEmpty($User.password))) {
        Write-Warning "The password for $($User.username) is nul or empty."
    }
    else {
        try {
            New-MsolUser -DisplayName $FullName `
                -FirstName $User.FirstName `
                -LastName $User.LastName `
                -UserPrincipalName $User.UserPrincipalName `
                -UsageLocation $User.UsageLocation `
                -LicenseAssignment $User.AccountSkuId `
                -Password (ConvertTo-SecureString $user.password -AsPlainText -Force) `
                -PasswordNeverExpires $true `
                -ForceChangePassword $False
            Write-Host "The user $($User.firstname) $($User.lastname) ($($User.username)) was created."
        }
        catch {
            Write-Error "The user $($User.firstname) $($User.lastname) ($($User.username)) was not created."
        }
    }
}