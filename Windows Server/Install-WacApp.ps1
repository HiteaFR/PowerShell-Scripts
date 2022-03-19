Function Install-WacApp {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("generate", "installed")]
        [string]$CertOption = "generate",
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [int]$Port = 443
    )

    $Output = (Join-Path $env:TEMP "WAC.msi")
    $Logfile = (Join-Path $env:TEMP "WAC.txt")

    Write-Host "Start Download to temp folder to $Output" -ForegroundColor Green

    Invoke-WebRequest "https://aka.ms/WACDownload" -OutFile "$Output"

    if ($CertOption -eq "generate") {
        $msiArgs = @("/i", "$Output", "/qn", "/L*v", "$Logfile", "SME_PORT=$($Port)", "SSL_CERTIFICATE_OPTION=$($CertOption)")
    }
    elseif ($CertOption -eq "installed") {
        $Thumbprint = Read-Host "Enter un certificate Thumbprint"
        $msiArgs = @("/i", "$Output", "/qn", "/L*v", "$Logfile", "SME_PORT=$($Port)", "SME_THUMBPRINT=$($Thumbprint)", "SSL_CERTIFICATE_OPTION=$($CertOption)")
    }
    else {
        return
    }

    Write-Host "Start Install WAC with port $Port, view logs at $Logfile" -ForegroundColor Green

    Start-Process msiexec.exe -ArgumentList $msiArgs -Wait -PassThru -Verb "RunAs"

    Write-Host "Create firewall rules for WAC access on any profiles" -ForegroundColor Green
    
    New-NetFirewallRule -DisplayName "Allow Windows Admin Center" -Direction Outbound -profile Any -LocalPort $Port -Protocol TCP -Action Allow

    New-NetFirewallRule -DisplayName "Allow Windows Admin Center" -Direction Inbound -profile Any -LocalPort $Port -Protocol TCP -Action Allow
    
}