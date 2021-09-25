[CmdletBinding()]

param (

    [Parameter(Mandatory = $false)]

    [string]

    $SubsID,

    [Parameter(Mandatory = $false)]

    [string]

    $FilePath = "$Env:USERPROFILE\Desktop\AzureMoveResourcesReport.docx"

)

Import-Module Az
Import-Module PSWriteWord


if ($SubsID) {

    Connect-AzAccount -Subscription $SubsID | Out-Null

}

else {

    Connect-AzAccount | Out-Null

}

$WordDocument = New-WordDocument $FilePath

#$res = Invoke-WebRequest -Uri https://raw.githubusercontent.com/tfitzmac/resource-capabilities/master/move-support-resources.csv -Method Get
#$list = Convertfrom-csv -InputObject $res.Content

$list = Import-Csv -Path "move-support-resources.csv"

$resGroups = Get-AzResourceGroup

foreach ($group in $resGroups) {

    $resObjs = Get-AzResource -ResourceGroupName $group.ResourceGroupName

    Add-WordText -WordDocument $WordDocument -Text "`nResources Group: $($group.ResourceGroupName)" -FontSize 20 -Color Blue -Supress $True
    Add-WordLine -WordDocument $WordDocument -LineColor Blue -LineType double -Supress $True

    foreach ($obj in $resObjs) {

        $resName = $obj.Name

        $resType = $obj.ResourceType

        $resID = $obj.ResourceId

        $resList = $list -match $obj.ResourceType

        if ($resList) {

            $i = [int]$resList[0].'Move Subscription'

            if ($i -ne 1) {

                Write-Host "`nOBJECT CAN _NOT_ BE MIGRATED: $resName has type $resType ($resID)" -ForegroundColor Yellow -BackgroundColor DarkRed
                Add-WordText -WordDocument $WordDocument -Text "`nOBJECT CAN _NOT_ BE MIGRATED: $resName has type $resType ($resID)" -FontSize 12 -Color Red -Supress $True  

            }

            else {

                Write-Host "`nOBJECT SUPPORTED FOR MIGRATION: $resName has type $resType ($resID)" -ForegroundColor Green
                Add-WordText -WordDocument $WordDocument -Text "`nOBJECT SUPPORTED FOR MIGRATION: $resName has type $resType ($resID)" -FontSize 12 -Color Green -Supress $True                

            }

        }

        else {

            Write-Host "UNKNOWN OBJECT's TYPE: $resName has type $resType ($resID)" -ForegroundColor DarkRed -BackgroundColor Yellow
            Add-WordText -WordDocument $WordDocument -Text "UNKNOWN OBJECT's TYPE: $resName has type $resType ($resID)" -FontSize 12 -Color Yellow -Supress $True  

        }

    }

}

Save-WordDocument $WordDocument -Language 'en-US' -Supress $True -OpenDocument:$true