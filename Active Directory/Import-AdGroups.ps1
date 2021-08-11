#Importer le module Active Directory
Import-Module activedirectory

$Rights = Import-csv "Templates\Import-AdGroups.csv" -Delimiter ";" -Encoding UTF8

# $Groups_Names = ($Rights[0].psobject.Properties).name | Where-Object { $_ -ne "Utilisateur" }
# $Groups_Names -contains $Property.name

ForEach ($User in $Rights) {
    ForEach ($Property in $User.PsObject.Properties) {
        if ($Property.Value -eq "0") {
            $Mode = "Access"
        }
        elseif ($Property.Value -eq "1") {
            $Mode = "Read"
        }
        elseif ($Property.Value -eq "2") {
            $Mode = "Write"
        }
        
        $Group = (($Property.name -replace " ", "-" -replace "\\", "_" -replace ",", "-") + "_" + $Mode)
        
        Try {

            $TheGroup = Get-ADGroup $Group
  
            try {
                Add-AdGroupMember -Identity ($($TheGroup.name)) -members $User.Utilisateur
                Write-Host "User $($User.Utilisateur) added to the group" ($($TheGroup.name)) -BackgroundColor Green
            }
            catch {
                Write-Host "User $($User.Utilisateur) not added to the group" ($($TheGroup.name)) -BackgroundColor Yellow
            } 

        } 
        Catch {
            Write-Host "Group $($Group) d'ont exist, skipped !" -BackgroundColor Red
        } 
    }
}