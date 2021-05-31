param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $Csv1,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $Csv2,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $Property
)

#Importer les 2 fichiers CSV
$File1 = Import-Csv -Path $Csv1 -Delimiter ";" -Encoding utf8
$File2 = Import-Csv -Path $Csv2 -Delimiter ";" -Encoding utf8

#Comparer les 2 objets importés
$Results = Compare-Object  $File1 $File2 -Property $Property -IncludeEqual

#Parcourir le tableau pour trouver les valeurs identiques
$Array = @()       
Foreach ($R in $Results) {
    If ( $R.sideindicator -eq "==" ) {
        $Object = [pscustomobject][ordered] @{
 
            "Valeurs identiques" = $R.$($Property)
 
        }
        $Array += $Object
    }
}

#Retourner le résultat
$Array

<#
.\Compare-Csv.ps1 -csv1 ".\templates\Compare-Csv-1.csv" -csv2 ".\Templates\Compare-Csv-2.csv" -property "Nom"
#>