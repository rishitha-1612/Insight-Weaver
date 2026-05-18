$ErrorActionPreference = "Stop"

$ScriptPath = Join-Path $PSScriptRoot "ensure-running.ps1"
$Action = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""

schtasks /Create /TN "InsightWeaverKeepAlive" /SC MINUTE /MO 5 /TR $Action /F | Out-Host
schtasks /Create /TN "InsightWeaverStartOnLogon" /SC ONLOGON /TR $Action /F | Out-Host

Write-Host "Created Insight Weaver scheduled tasks."
