# Liste des serveurs  pour le rapport
$ServerList = ""

# Vérifier le fichier
If (!(Test-Path $ServerList)) {
    Write-Host "Can not get servers list. Script will not continue" -ForegroundColor Red; Exit
}

$servers = @()
$job_details = ""

Get-Content $ServerList | Foreach-Object { $servers += $_ }

for ($i = 0; $i -lt $servers.length; $i++) {
    $ConnectionError = 0
    Write-Host "Getting result from server: " $servers[$i]
    try {
        $Session = New-PSSession -ComputerName $servers[$i]
        $WindowsVersion = Invoke-Command -session $session -ScriptBlock { (Get-WmiObject win32_operatingsystem).version }
        if ($WindowsVersion -match "6.1")
        { $WBSummary = Invoke-Command -session $session -ScriptBlock { add-pssnapin windows.serverbackup; Get-WBSummary } }
        else { $WBSummary = Invoke-Command -session $session -ScriptBlock { Get-WBSummary } }
        Remove-PSSession $Session
    }
    catch {
        Write-Host "Error connecting remote server"
        write-host "Caught an exception:" -ForegroundColor Red
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red 
        $ConnectionError = 1
    }
             

    $job_details += "## Serveur : " + $servers[$i] + "`n"

    if ($ConnectionError -eq 1) {
        $job_details += "- **Statut** : Error connecting remote server`n"
    }
    else {
        if ($WBSummary.LastBackupResultHR -eq 0) { $job_details += "- **Statut** : Success`n"; $result = "Success" }
        else { $job_details += "- **Statut** : Failure`n"; $result = "Failure" }
        
        $job_details += "- **Date** : " + $WBSummary.LastSuccessfulBackupTime + "`n"
   
        if ([string]::IsNullOrEmpty($WBSummary.DetailedMessage)) { $job_details += "- **Message** : Success`n"; $message = "Success" }
        else { $job_details += "- **Message** : " + $WBSummary.DetailedMessage + "`n"; $message = $WBSummary.DetailedMessage }

        $job_details += "- **Nombre de sauvegardes** : " + $WBSummary.NumberOfVersions + "`n"

        if ([string]::IsNullOrEmpty($WBSummary.LastBackupTarget)) { $job_details += "- **Destination** : None`n" }
        else { $job_details += "- **Destination** : " + $WBSummary.LastBackupTarget + "`n" }
               
        Write-Host "Last Backup Result: $result"
        Write-Host "Last Successful Backup Time:" $WBSummary.LastSuccessfulBackupTime
        Write-Host "Detailed Message: $message"
        Write-Host "Number of Backups:" $WBSummary.NumberOfVersions
        Write-Host "Destination:" $WBSummary.LastBackupTarget
        Write-Host "-----------------------------------------------------------------"
            
    }
}
