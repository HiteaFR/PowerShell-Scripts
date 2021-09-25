New-SelfSignedCertificate -Subject “CertName” -DnsName "CertFqdn” -CertStoreLocation “cert:\LocalMachine\My” -KeyAlgorithm RSA -KeyLength 2048 -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears(5)

$pwd = ConvertTo-SecureString -String "Password" -Force –AsPlainText

Export-PfxCertificate -cert cert:\localMachine\my\785810C7545A00609AA3623159DA3E6E01F265DB -FilePath e:\cert.pfx -Password $pwd
