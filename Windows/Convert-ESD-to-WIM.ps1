#Convertir une image Windows au format ESD en WIM

#Monter l'ISO, se rendre dans le dossier sources

#Récupérer les versions disponibles
dism /Get-WimInfo /WimFile:install.esd

#Extraire la version pro par exemple (Index 6), il faut aussi modifier la destination vers un dossier conne C:\images\install.wim par exemple
dism /export-image /SourceImageFile:install.esd /SourceIndex:6 /DestinationImageFile:install.wim /Compress:max /CheckIntegrity