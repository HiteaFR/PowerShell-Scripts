# Import active directory module for running AD cmdlets
Import-Module MSOnline
  
#Store the data from ADUsers.csv in the $ADUsers variable
$AADUsers = Import-csv "Templates\Import-MsolUsers.csv" -Delimiter ";" -Encoding UTF8

#Loop through each row containing user details in the CSV file 
foreach ($User in $AADUsers) {
    Set-MsolUserPassword -UserPrincipalName $User.Username -NewPassword $user.password -ForceChangePassword $false
}
