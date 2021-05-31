param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Group
)

#Vérifier si le groupe existe et si l'utilisateur est membres
try {
    $GroupMembers = Get-LocalGroupMember -Group $Group -ErrorAction Stop
    if ($GroupMembers -match $Name) {
        #Si oui retourner OUI
        return $true
    }
    else {
        #Sinon retourner NON
        return $false
    }
}
catch {
    Write-Host "Group doesn't exist"
}
