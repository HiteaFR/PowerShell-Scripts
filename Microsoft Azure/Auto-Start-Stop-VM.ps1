# Input bindings are passed in via param block.
param($Timer)

# Add all your Azure Subscription Ids below
$subscriptionids = @"
[
    "SOUSCRIPTION ID"
]
"@ | ConvertFrom-Json

# Convert UTC to West Europe Standard Time zone
$date = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"W. Europe Standard Time")

foreach ($subscriptionid in $subscriptionids) {

# Selecting Azure Sub
Set-AzContext -SubscriptionId $subscriptionid | Out-Null

$CurrentSub = (Get-AzContext).Subscription.Id
If ($CurrentSub -ne $SubscriptionID) {
Throw "Could not switch to SubscriptionID: $SubscriptionID"
}

$vms = Get-AzVM -Status | Where-Object {($_.tags.AutoShutdown -ne $null) -or ($_.tags.AutoStart -ne $null)}
write-host "found VMs : " $vms.Count 

$now = $date

foreach ($vm in $vms) {

write-host "handling Vm : " $vm.name 
if (($vm.tags.AutoShutdown -ne $null) -and ($vm.PowerState -eq 'VM running') -and ( $now -gt $(get-date $($vm.tags.AutoShutdown)) ) ) {
    Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Confirm:$false -Force
    Write-Warning "Stop VM - $($vm.Name)"
}
elseif (($vm.tags.AutoStart -ne $null) -and ($vm.PowerState -ne 'VM running') -and ( $now -gt $(get-date $($vm.tags.AutoStart)) ) -and ( $now -lt $(get-date $($vm.tags.AutoShutdown)) ) ) {
    Start-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName
    Write-Warning "Start VM - $($vm.Name)"
}

}
}