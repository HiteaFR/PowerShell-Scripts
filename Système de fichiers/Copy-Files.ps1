#Copier un fichier
Copy-Item "SOURCE" -Destination "DESTINATION"

#Télécharger un fichier depuis le Web
Invoke-WebRequest 'https://aka.ms/WACDownload' -OutFile "DESTINATION.msi"

#Copier des fichiers et dossiers avec BITS
Start-BitsTransfer -Source "SOURCE\*" -Destination "DESTINATION"

#Copier des fichiers et dossiers avec Robocopy et PowerShell en mode miroir

##La commande de base
robocopy "SOURCE" "DEST" /MIR /NDL /NP /FFT /Z /R:3 /W:10 /LOG+:C:\Lab\Log.txt

##Importer le CSV qui contient les sources et destinations
$Files = Import-Csv "Copy-Files.csv" -Encoding "UTF8" -Delimiter ";"

##Définir le dossier de logs
$RootLogs = "C:\Lab"

##Parcourir les lignes du CSV et créer des tâches Robocopy
foreach ($Item in $Files) {
    $Logs = $RootLogs + "\Logs_" + (Get-Date -UFormat "%d-%m-%Y") + ".log"
    $RobocopyParams = "/MIR /NDL /NP /FFT /Z /R:1 /W:5 /LOG+:$Logs"
    New-Item -Path $Item.Destination -ItemType Directory -Force
    Start-Process "robocopy.exe" -Argumentlist `"$($Item.Source)`", `"$($Item.Destination)`", $RobocopyParams -Wait
}