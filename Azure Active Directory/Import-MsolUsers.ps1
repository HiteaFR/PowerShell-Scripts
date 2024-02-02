# Import active directory module for running AD cmdlets
Import-Module MSOnline
  
#Store the data from ADUsers.csv in the $ADUsers variable
$AADUsers = Import-csv "Import-MsolUsers.csv" -Delimiter ";" -Encoding UTF8

$outFile = "Import-MsolUsers-Result.csv"

$outArray = @()

#Loop through each row containing user details in the CSV file 
foreach ($User in $AADUsers) {

    $myobj = New-Object System.Object

    $FullName = "$($User.firstname) $($User.lastname)"

    # $Password = [System.Web.Security.Membership]::GeneratePassword(10, 1)
    $Password = $($User.password)

    if ((Get-MsolUser -UserPrincipalName $User.username -ErrorAction SilentlyContinue)) {
        Write-Warning "A user account with UPN $($User.username) already exist in Azure Active Directory."
    }
    elseif (([string]::IsNullOrEmpty($Password))) {
        Write-Warning "The password for $($User.username) is nul or empty."
    }
    else {
        try {
            New-MsolUser -DisplayName $FullName `
                -FirstName $User.FirstName `
                -LastName $User.LastName `
                -UserPrincipalName $User.Username `
                -UsageLocation $User.UsageLocation `
                -LicenseAssignment $User.AccountSkuId `
                -Password $Password `
                -PasswordNeverExpires $true `
                -ForceChangePassword $true
            Write-Host "The user $($User.firstname) $($User.lastname) ($($User.username)) was created."

            $myObj | Add-Member -type NoteProperty -name FirstName -value $User.FirstName
            $myObj | Add-Member -type NoteProperty -name LastName -value $User.LastName
            $myObj | Add-Member -type NoteProperty -name DisplayName -value $FullName
            $myObj | Add-Member -type NoteProperty -name UserPrincipalName -value $User.Username
            $myObj | Add-Member -type NoteProperty -name Password -value $Password
            $outArray += $myObj
        }
        catch {
            Write-Error "The user $($User.firstname) $($User.lastname) ($($User.username)) was not created."
        }
    }

    Start-Sleep -Seconds 80

}

$outArray | Export-CSV $outfile -notypeinformation -Encoding UTF8 -Delimiter ";"