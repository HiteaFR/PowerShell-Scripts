# Before using this script you must register the PNP App with the Cmdlet : Register-PnPManagementShellAccess

$creduser = Read-Host "Admin email"
$credpassword = Read-Host "Admin Password"
$SiteURL = Read-Host "Site library URL"
$ListName = Read-Host "List Name"

[securestring]$secStringPassword = ConvertTo-SecureString $credpassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($creduser, $secStringPassword)

Connect-AzureAD -Credential $credObject

Connect-PnPOnline -Url $SiteURL -Credentials $credObject

$Table2 = New-Object 'System.Collections.Generic.List[System.Object]'

$SpFolderList = Get-PnPFolderItem -FolderSiteRelativeUrl $ListName -ItemType Folder

foreach ($Folder in $SpFolderList) {

    $context = Get-PnPContext
    $file = Get-PnPFolder -Url $Folder.ServerRelativeUrl -Includes ListItemAllFields.RoleAssignments, ListItemAllFields.HasUniqueRoleAssignments
    $context.Load($file);
    $context.ExecuteQuery();

    if ($file.ListItemAllFields.HasUniqueRoleAssignments -eq $True) {
        foreach ($roleAssignments in $file.ListItemAllFields.RoleAssignments) {
            Get-PnPProperty -ClientObject $roleAssignments -Property RoleDefinitionBindings, Member
            $PermissionType = $roleAssignments.Member.PrincipalType
            $PermissionLevels = $roleAssignments.RoleDefinitionBindings | Select-Object -ExpandProperty Name
            $PermissionLevels = ($PermissionLevels | Where-Object { $_ -notlike "Acc*s limit*" }) -join ", "
            If ($PermissionLevels.Length -eq 0) { Continue }
            if ($PermissionType -eq "SecurityGroup") {

                $Group = Get-AzureAdGroup -Filter "DisplayName eq '$($roleAssignments.Member.Title)'" | Where-Object { $_.MailEnabled -eq $false -and $_.SecurityEnabled -eq $true }
                
                if (!$Group) {
                    $Users = "Groupe Introuvable: Erreur"
                }
                else {
                    $Users = (Get-AzureADGroupMember -ObjectId $Group.ObjectID | Sort-Object DisplayName | Select-Object -ExpandProperty DisplayName) -join ", "
                }


                $obj2 = [PSCustomObject]@{
                    'Dossier' = $Folder.Name
                    'Type'    = $PermissionType
                    'Nom'     = $roleAssignments.Member.Title
                    'Membres' = $Users
                    'Droit'   = $PermissionLevels
                }
            }
            else {
                $obj2 = [PSCustomObject]@{
                    'Dossier' = $Folder.Name
                    'Type'    = $PermissionType
                    'Nom'     = $roleAssignments.Member.Title
                    'Membres' = ""
                    'Droit'   = $PermissionLevels
                }
            }
            $table2.add($obj2)
        }
    }

}

$table2 | Export-Csv -Path "Dossier-SharePoint.csv" -Delimiter ";" -Encoding UTF8 -NoTypeInformation

try {
    Import-Module -Name PSWriteHTML
    New-HTML {
        New-HTMLTable -DataTable $table2 -Title 'SharePoint Library Rights' -HideFooter -PagingLength 25 -AlphabetSearch {
            New-TableAlphabetSearch -ColumnName 'Name'
        }
    } -ShowHTML -FilePath "SharePointReport.html" -Online
}
catch {
    { Write-Host "PSWriteHTLM module is not present" }
}
