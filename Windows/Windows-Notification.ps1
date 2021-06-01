[CmdletBinding(
    SupportsShouldProcess = $true
)]
Param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Info", "Warning", "Error", "None")]
    [string]$Type,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Title,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Text,
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [int]$Timeout = 10
)      

#Ajouter les librairies Windows
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Créer l'objet notification
$notify = new-object system.windows.forms.notifyicon
$notify.icon = [system.drawing.icon]::ExtractAssociatedIcon((join-path $pshome powershell.exe))
$notify.visible = $True

$notify.showballoontip($Timeout, $title, $text, $type)

switch ($Host.Runspace.ApartmentState) {
    STA {
        $null = Register-ObjectEvent -InputObject $notify -EventName BalloonTipClosed -Action {
            $Sender.Dispose()
            Unregister-Event $EventSubscriber.SourceIdentifier
            Remove-Job $EventSubscriber.Action
        }
    }
    default {
        continue
    }
}