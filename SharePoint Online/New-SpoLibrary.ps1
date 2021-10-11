$creduser = Read-Host "Admin email"
$credpassword = Read-Host "Admin Password"

[securestring]$secStringPassword = ConvertTo-SecureString $credpassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($creduser, $secStringPassword)

Connect-AzureAD -Credential $credObject

$SiteURL = "Site library URL"
$Library = "List Name"

Connect-PnPOnline -Url $SiteURL -UseWebLogin

$MemberGroup = Get-PnPGroup -Identity "Site de partage - Membres"

$CsvFolderList = Import-csv "SharePoint_Config_Sub.csv" -Delimiter ";" -Encoding UTF8

foreach ($folder in $CsvFolderList) {

    $NewFolder = Add-PnPFolder -Name $folder.name -Folder $Library

    $NewFolderUrl = Get-PnPFolder -Url ($Library + "/" + $NewFolder.name) -Includes ListItemAllFields.HasUniqueRoleAssignments

    If ($NewFolderUrl.ListItemAllFields.HasUniqueRoleAssignments) {
        Write-host "Folder is already with broken permissions!" -f Yellow
    }
    Else {
        Write-Host $NewFolderUrl

        $NewFolderUrl.ListItemAllFields.BreakRoleInheritance($True, $True)

        Invoke-PnPQuery
 
        Write-host "Folder's Permission Inheritance is broken!!" -f Green   
    }

}

foreach ($folder in $CsvFolderList) {

    $ADgroupname = (Get-AzureADGroup | where { $_.displayname -eq $folder.Group } ).objectid

    $SpFolder = Get-PnPFolder -Url ("/sites/partage" + $Library + "/" + $folder.name)

    Set-PnPListItemPermission -List $Library -Identity ($folder.ListItemAllFields) -Group $MemberGroup -RemoveRole 'Lecture'

    Set-PnPfolderPermission -list $Library -identity $SpFolder -user "c:0t.c|tenant|$ADGroupName" -AddRole 'Collaboration'
}

foreach ($folder in $CsvFolderList) {

    Add-PnPFolder -Name $folder.name -Folder ($Library + "/" + $folder.parent)

}