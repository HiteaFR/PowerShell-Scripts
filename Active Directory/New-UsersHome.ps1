<#
 
    .SYNOPSIS
    Créer des dossiers utilisateurs avec les autorisations contrôle total
   
    .PARAMETER Domain
    Indique le domaine
   
    .PARAMETER BaseDir
    Indique le dossier racine
   
    .EXAMPLE
    New-UsersHome -Domain "@Domaine.local" -BaseDir "C:\UsersHome"
 
#>
 
param (
    [parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]$Domain,
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]$BaseDir
)

# Lister tous les utilisateurs du domaine
$Users = Get-ADUser -Filter { UserPrincipalName -like "*$($Domain)" } | Select SAMAccountName, SID

# Déactiver l'héritage sur le dossier racine et supprimer les autorisation Utilisateurs
Foreach ($User in $Users) {

    $UserDir = Join-Path $BaseDir $User.SAMAccountName

    If (!(test-path $UserDir)) {
        New-Item -ItemType Directory -Path $UserDir
    }

    $acl = Get-Acl $UserDir
    $acl.SetAccessRuleProtection($true, $true)
 
    $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"FullControl"
    $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None
 
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($User.SID, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
    $acl.AddAccessRule($AccessRule)
 
    Set-Acl -Path $UserDir -AclObject $acl -ea Stop

}

