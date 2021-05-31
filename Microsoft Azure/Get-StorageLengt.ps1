#Reprise d'un exemple officiel pour calculer la taile d'un conteneur Blob sur Azure
#Attention les opérations de lecture sont facturables !

# these are for the storage account to be used
$resourceGroup = ""
$storageAccountName = ""
$containerName = ""

# get a reference to the storage account and the context
$storageAccount = Get-AzStorageAccount `
    -ResourceGroupName $resourceGroup `
    -Name $storageAccountName
$ctx = $storageAccount.Context 

# get a list of all of the blobs in the container 
$listOfBLobs = Get-AzStorageBlob -Container $ContainerName -Context $ctx 

# zero out our total
$length = 0

# this loops through the list of blobs and retrieves the length for each blob
#   and adds it to the total
$listOfBlobs | ForEach-Object { $length = $length + $_.Length }

# output the blobs and their sizes and the total 
Write-Host "List of Blobs and their size (length)"
Write-Host " " 
$listOfBlobs | select Name, Length
Write-Host " "
Write-Host "Total Length = " $length