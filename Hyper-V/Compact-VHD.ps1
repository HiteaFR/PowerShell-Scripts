# Importer le moudule Hyper-V
Import-Module -Name Hyper-V

# Chemin du VHD et mode de compactage
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][String]$Path,
    [Parameter()][Microsoft.Vhd.PowerShell.VhdCompactMode]$Mode = [Microsoft.Vhd.PowerShell.VhdCompactMode]::Full
)

# Vérifier le fichier
try {
    $Path = (Resolve-Path -Path $Path -ErrorAction Stop).Path
    if ($Path -notmatch '\.a?vhdx?$') { throw }
}
catch {
    throw('{0} is not a valid VHDX file.' -f $Path)
}

# Monter le VHD
Mount-VHD -Path $Path -ReadOnly -ErrorAction Stop

# Compacter le VHD
Optimize-VHD -Path $Path -Mode $Mode -ErrorAction Continue

# Démonter le VHD
Dismount-VHD -Path $Path
