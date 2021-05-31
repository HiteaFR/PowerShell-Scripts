#Il faut installer l'outil AZCopy

#Se rendre dans le repertoire d'AZCopy
cd "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"

#Définir la source des PST
$PSTFile = "\\SRV01\PSTImport"

#Définir l'URL du blob Azure
$AzureStore = "AZ_BLOB_URL"

#Définir le chemin du fichier log
$LogFile = "C:\importPST_log.txt"
 
#Lancer l'upload vers Azure
& .\AzCopy.exe /Source:$PSTFile /Dest:$AzureStore /V:$LogFile /Y