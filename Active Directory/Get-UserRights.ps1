#Paremetres Utilisateur et racine du partage

$User = "Username"
$Path = "PATH"

#Nom de Domaine NetBios
$Domain = "DOMSNS"

Function Get-ADUserNestedGroups {
    Param
    (
        [string]$DistinguishedName,
        [array]$Groups = @()
    )

    #Get the AD object, and get group membership.
    $ADObject = Get-ADObject -Filter "DistinguishedName -eq '$DistinguishedName'" -Properties memberOf, DistinguishedName;
    
    #If object exists.
    If ($ADObject) {
        #Enummurate through each of the groups.
        Foreach ($GroupDistinguishedName in $ADObject.memberOf) {
            #Get member of groups from the enummerated group.
            $CurrentGroup = Get-ADObject -Filter "DistinguishedName -eq '$GroupDistinguishedName'" -Properties memberOf, DistinguishedName;
       
            #Check if the group is already in the array.
            If (($Groups | Where-Object { $_.DistinguishedName -eq $GroupDistinguishedName }).Count -eq 0) {
                #Add group to array.
                $Groups += $CurrentGroup;

                #Get recursive groups.      
                $Groups = Get-ADUserNestedGroups -DistinguishedName $GroupDistinguishedName -Groups $Groups;
            }
        }
    }

    Return $Groups;
}

$Groups = Get-ADUserNestedGroups -DistinguishedName (Get-ADUser -Identity $User).DistinguishedName;

$list = Get-ChildItem $Path -Recurse -Directory

Foreach ($item in $list) {

    $ACL = (Get-Acl $item.FullName).Access

    if (($ACL.IdentityReference -contains ("$($Domain)\" + $User)) -and ($ACL.IsInherited -eq $false)) {

        Write-Host "$($User) a les droits $($ACL.FileSystemRights) sur $($item.FullName)"

    }

    Foreach ($Group in $Groups.Name) {

        if (($ACL.IdentityReference -contains ("$($Domain)\" + $Group)) -and ($ACL.IsInherited -eq $false)) {

            Write-Host "$($User) est dans le groupe $($Group) qui a les droits $($ACL.FileSystemRights) sur $($item.FullName)"

        }

    }

}