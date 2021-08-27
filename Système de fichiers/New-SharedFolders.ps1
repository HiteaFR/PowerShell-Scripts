Import-Module activedirectory

$Partages = Import-csv "Templates\New-SharedFolders.csv" -Delimiter ";" -Encoding UTF8
$BaseDir = "D:\Partages\"

$searchbase = Get-ADDomain | ForEach-Object { $_.DistinguishedName }
$netbios = Get-ADDomain | ForEach-Object { $_.NetBIOSName }

ForEach ($item In $Partages) {

    if ($item.AccessType -eq "Write") {
        $Rights = "Modify, Synchronize"
        $Inheritance = "ContainerInherit, ObjectInherit"
        $Propagation = "None"
        $AccessControlType = "Allow"
    }
    elseif ($item.AccessType -eq "Read") {
        $Rights = "ReadAndExecute"
        $Inheritance = "ContainerInherit, ObjectInherit"
        $Propagation = "None"
        $AccessControlType = "Allow"
    }
    elseif ($item.AccessType -eq "Access") {
        $Rights = "ReadAndExecute"
        $Inheritance = "None"
        $Propagation = "None"
        $AccessControlType = "Allow"
    }
    else {
        Write-Host "AccessType is empty"
        Return
    }

    $Shared_Folder = Join-Path $BaseDir $item.Name

    try {
        if (Test-Path $Shared_Folder) {
            Write-Host "Folder $($Shared_Folder) alread exists! Folder creation skipped!"
        }
        else {
            New-Item -ItemType Directory -Path $Shared_Folder
            Write-Host "Folder $($Shared_Folder) created!"
        }
    }
    catch {
        Write-Host "Error, Folder $($Shared_Folder) not created!"
    }

    if (($item.IsShared -eq $true) -and (!(Get-SmbShare -Name $item.Name -ErrorAction SilentlyContinue))) {
        try {
            New-SmbShare -Name $item.Name -Path $Shared_Folder -FullAccess "Tout le monde"
            Set-SmbShare -Name $item.Name -FolderEnumerationMode AccessBased -Force
            Write-Host "$($Shared_Folder) is shared now!"
        }
        catch {
            Write-Host "Error, $($Shared_Folder) not shared!"
        }
    }
    else {
        Write-Host "Folder $($Shared_Folder) is already shared or IsShared is not set to true!"
    }

    $check = [ADSI]::Exists("LDAP://$($item.GroupLocation),$($searchbase)")

    $Group = (($item.name -replace " ", "-" -replace "\\", "_" -replace ",", "-") + "_" + $item.AccessType)

    If ($check -eq $True) {
        Try { 
            $TheGroup = Get-ADGroup $Group
            Write-Host "Group $($Group) alread exists! Group creation skipped! SID: $($TheGroup.SID)"
        } 
        Catch {

            $TheGroup = New-ADGroup -Name $Group -Path ($($item.GroupLocation) + "," + $($searchbase)) -GroupCategory Security -GroupScope $item.GroupType -PassThru -Verbose
            Write-Host "Group $($Group) created! SID: $($TheGroup.SID)"
        } 

        try {
            $acl = Get-Acl $Shared_Folder

            if ($acl.Access.IdentityReference -notcontains ($($netbios) + "\" + $Group)) {

                $acl.SetAccessRuleProtection($true, $true)

                $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($TheGroup.SID, $Rights, $Inheritance, $Propagation, $AccessControlType)
                $acl.AddAccessRule($AccessRule)

                Set-Acl -Path $Shared_Folder -AclObject $acl -ea Stop

                Write-Host "ACL for $($Shared_Folder) created!"
            }
            else {
                Write-Host "ACL for $($Shared_Folder) alread exists! Folder ACL skipped!"
            }
            $acl = Get-Acl $Shared_Folder
            $objUser = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-545") 
            $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, "FullControl", "None", "None", "Allow")
            $acl.RemoveAccessRuleAll($objACE)

            Set-Acl -Path $Shared_Folder -AclObject $acl -ea Stop

        }
        catch {
            Write-Host "Error, ACL for folder $($Shared_Folder) not modified!"
        }

    }
    Else { 
        Write-Host "Target OU can't be found! Group creation skipped!" 
    }

}
