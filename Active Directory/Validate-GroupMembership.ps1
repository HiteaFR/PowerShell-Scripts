<#
 
    .SYNOPSIS
    Validates AD group membership for a user or computer object
   
    .PARAMETER SearchString
    Provide Username or Computer Name
   
    .PARAMETER SearchType
    Specify type (User or Computer)
 
    .PARAMETER Group
    Provide AD Group name
   
    .EXAMPLE
    Validate-GroupMembership -SearchString $env:USERNAME -SearchType User -Group "Test Group"
   
    .EXAMPLE
    Validate-GroupMembership -SearchString $env:COMPUTERNAME -SearchType Computer -Group "ORL Computers"
 
#>
 
param (
    [parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]$SearchString,
    [parameter(Mandatory = $True)]
    [ValidateSet("User", "Computer")]
    [ValidateNotNullOrEmpty()]$SearchType,
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]$Group
)
 
Try {
 
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry
 
    If ($SearchType -eq "User") {
 
        $objSearcher.Filter = "(&(objectCategory=User)(SAMAccountName=$SearchString))"
 
    } 
    Else {
 
        $objSearcher.Filter = "(&(objectCategory=Computer)(cn=$SearchString))"
 
    }
 
    $objSearcher.SearchScope = "Subtree"
    $obj = $objSearcher.FindOne()
    $User = $obj.Properties["distinguishedname"]
 
    $objSearcher.PageSize = 1000
    $objSearcher.Filter = "(&(objectClass=group)(cn=$Group))"
    $obj = $objSearcher.FindOne()
 
    [String[]]$Members = $obj.Properties["member"]
 
    If ($Members.count -eq 0) {                       
 
        $retrievedAllMembers = $false          
        $rangeBottom = 0
        $rangeTop = 0
 
        While (! $retrievedAllMembers) {
 
            $rangeTop = $rangeBottom + 1499               
 
            $memberRange = "member;range=$rangeBottom-$rangeTop" 
 
            $objSearcher.PropertiesToLoad.Clear()
            [void]$objSearcher.PropertiesToLoad.Add("$memberRange")
 
            $rangeBottom += 1500
 
            Try {
 
                $obj = $objSearcher.FindOne() 
                $rangedProperty = $obj.Properties.PropertyNames -like "member;range=*"
                $Members += $obj.Properties.item($rangedProperty)          
                    
                if ($Members.count -eq 0) { $retrievedAllMembers = $true }
            }
 
            Catch {
 
                $retrievedAllMembers = $true
            }
 
        }
             
    }
 
}
 
Catch {
 
    Write-Host "Either group or user does not exist"
    Return $False
 
}
    
If ($Members -contains $User) { 
 
    Return $True
 
}
Else {
 
    Return $False
 
}