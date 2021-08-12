function New-Certificate {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Export = $false
    )

    $OldCert = Get-ChildItem -Path cert:\CurrentUser\My | Where-Object { $_.FriendlyName -eq $Name }
    if ($OldCert) {
        Write-Host "Cert Alreday Exist, Return "
        Return
    }
    else {
        $Create_Cert = New-SelfSignedCertificate -Subject "CN=$Name" -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsage KeyEncipherment, DataEncipherment, KeyAgreement -Type DocumentEncryptionCert -FriendlyName $Name
        Write-Host "New Certificate created"
        if (($Export -eq $true)) {
            if (Test-Path ($Name + "_Cert_Export.pfx")) {
                Remove-Item (Join-Path ($Name + "_Cert_Export.pfx"))
                Write-Verbose -Message "File alreday exist: removed"
            }
            $cert = Get-ChildItem -Path cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $($Create_Cert.Thumbprint) }
            Export-PfxCertificate -Cert $cert -FilePath ($Name + "_Cert_Export.pfx") -Password (ConvertTo-SecureString -AsPlainText $Password -Force)
            Write-Host "Certificate Exported"
        }
    }
}
