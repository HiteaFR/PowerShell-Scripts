#A faire sur un controleur de domaine par exemple
#Si le controleur est une VM Hyper-V, il faut déactiver la synchro de l'heure pour cette VM

#Sur le DC
w32tm /config /update /manualpeerlist:"time.windows.com,0x8" /syncfromflags:MANUAL
Restart-Service w32time
w32tm /resync

#Vérifier la propagation sur les PC du domaine
w32tm /resync
w32tm /query /status

#Vérifier la source de temps
w32tm /query /source