# Obtenir la liste des services Exchange qui sont démarrer

$services = Get-Service | ? { $_.name -like "MSExchange*" -and $_.Status -eq "Running" }
 
# Redémarrer les services

foreach ($service in $services) {
	Restart-Service $service.name -Force
}