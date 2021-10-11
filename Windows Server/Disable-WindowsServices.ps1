$onesync = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services' | ? { $_.PSChildName -like "OneSync*" }).Name

$Services =
@("bthserv - Bluetooth Support Service.", "bthserv"),
  ("DcpSvc - DataCollectionPublishingService.", "DcpSvc"),
  ("DPS - Diagnostic Policy Service.", "DPS"),
  ("WdiServiceHost - Diagnostic Service Host.", "WdiServiceHost"),
  ("WdiSystemHost - Diagnostic System Host.", "WdiSystemHost"),
  ("DiagTrack - Connected User Experiences and Telemetry [Diagnostics Tracking Service].", "DiagTrack"),
  ("dmwappushservice - dmwappushsvc.", "dmwappushservice"),
  ("MapsBroker - Downloaded Maps Manager.", "MapsBroker"),
  ("lfsvc - Geolocation Service.", "lfsvc"),
  ("UI0Detect - Interactive Services Detection.", "UI0Detect"),
  ("SharedAccess - Internet Connection Sharing [ICS].", "SharedAccess"),
  ("lltdsvc - Link-Layer Topology Discovery Mapper.", "lltdsvc"),
  ("diagnosticshub.standardcollector.service - Microsoft [R] Diagnostics Hub Standard Collector Service.", "diagnosticshub.standardcollector.service"),
  ("NcbService - Network Connection Broker.", "NcbService"),
  ("NcaSvc - Network Connectivity Assistant.", "NcaSvc"),
  ("defragsvc - Optimize drives.", "defragsvc"),
  ("wercplsupport - Problem Reports and Solutions Control Panel.", "wercplsupport"),
  ("PcaSvc - Program Compatibility Assistant Service.", "PcaSvc"),
  ("QWAVE - Quality Windows Audio Video Experience.", "QWAVE"),
  ("RmSvc - Radio Management Service.", "RmSvc"),
  ("SysMain - Superfetch.", "SysMain"),
  ("TapiSrv - Telephony.", "TapiSrv"),
  ("UALSVC - User Access Logging Service.", "UALSVC"),
  ("WerSvc - Windows Error Reporting Service.", "WerSvc"),
  ("wisvc - Windows Insider Service.", "wisvc"),
  ("icssvc - Windows Mobile Hotspot Service.", "icssvc"),
  ("XblAuthManager - Xbox Live Auth Manager.", "XblAuthManager"),
  ("XblGameSave - Xbox Live Game Save.", "XblGameSave")

foreach ($Service in $Services) {
    Write-Host Disabling service $Service[0] -ForegroundColor Cyan
    Invoke-Expression ("Set-Service " + $Service[1] + " -StartupType Disabled")
    Get-Service $Service[1] | Stop-Service -Force
    Start-Sleep 2
}

Set-Location HKLM:\
ForEach ($sync in $onesync) {
    Set-ItemProperty -Path $sync -Name Start -Value 4
}
Get-Service OneSync* | Stop-Service -Force