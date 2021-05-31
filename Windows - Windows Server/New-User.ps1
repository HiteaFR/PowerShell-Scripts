param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Password,
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Group = "Utilisateurs"
)

#Vérifier si l'utilisateur existe déjà
try {
    Get-LocalUser -Name $Name -ErrorAction Stop
    Write-Host "User already exist, reseting the password..." -ForegroundColor Yellow
    Set-LocalUser -Name $Name -Password (ConvertTo-SecureString -AsPlainText $Password -Force)
}
catch {
    #Créer l'utilisateur
    try {
        New-LocalUser -Name $Name -Password (ConvertTo-SecureString -AsPlainText $Password -Force) -FullName $Name -Description "Created date: $(Get-Date)" -ErrorAction Stop
        Write-Host "User created" -ForegroundColor Green
    }
    catch {
        Write-Host "Error: User not created" -ForegroundColor Red
    }
}
try {
    try {
        #Vérifier si le groupe existe et si l'utilisateur n'est pas déjà membre
        $GroupMembers = Get-LocalGroupMember -Group $Group -ErrorAction Stop
        if ($GroupMembers -match $Name) {
            Write-Host "User already in the group" -ForegroundColor Yellow
        }
        else {
            #Ajouter l'utilisateur au groupe
            Add-LocalGroupMember -Group $Group -Member $Name -ErrorAction Stop
        }
    }
    catch {
        Write-Host "Group doesn't exist" -ForegroundColor Red
    }
}
catch {
    Write-Host "Error: Unable to add the user to the group" -ForegroundColor Red
}