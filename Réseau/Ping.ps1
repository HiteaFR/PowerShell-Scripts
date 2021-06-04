#Fonctionne avec PowerShell 7

#Ping d'un plage d'IP de 192.168.1.1 à 192.168.1.254
1..254 | ForEach-Object -ThrottleLimit 50 -Parallel {
    Test-Connection "192.168.1.$_" -Count 1 -TimeoutSeconds 2 -ErrorAction SilentlyContinue -ErrorVariable e
    if ($e)
    {
        [PSCustomObject]@{ Destination = $_; Status = $e.Exception.Message }
    }
} | Group-Object Destination | Select-Object Name, @{n = 'Status'; e = { $_.Group.Status } } | Where-Object Status -eq "Success" | Sort-Object { [system.version[]]($_.Name) }

#Ping à partir d'une liste d'IP dans un CSV
Import-Csv -path Ping.csv -Encoding UTF8 | ForEach-Object -ThrottleLimit 5 -Parallel {
    Test-Connection $_.IP -Count 1 -TimeoutSeconds 2 -ErrorAction SilentlyContinue -ErrorVariable e
    if ($e)
    {
        [PSCustomObject]@{ Destination = $_; Status = $e.Exception.Message }
    }
} | Group-Object Destination | Select-Object Name, @{n = 'Status'; e = { $_.Group.Status } } | Sort-Object { [system.version[]]($_.Name) }