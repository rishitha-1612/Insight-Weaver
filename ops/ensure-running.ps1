param(
    [int]$DockerWaitSeconds = 45
)

$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent $PSScriptRoot
$Log = Join-Path $PSScriptRoot "keep-alive.log"
$DockerDesktop = "C:\Program Files\Docker\Docker\Docker Desktop.exe"

function Write-KeepAliveLog {
    param([string]$Message)
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $Log -Value "[$stamp] $Message"
}

Write-KeepAliveLog "keep-alive tick"

Set-Location $Root
docker compose up -d *> $null
if ($LASTEXITCODE -eq 0) {
    Write-KeepAliveLog "compose stack ensured"
} else {
    Write-KeepAliveLog "docker compose up failed with exit code $LASTEXITCODE; attempting Docker Desktop start"
    if (Test-Path $DockerDesktop) {
        Start-Process -FilePath $DockerDesktop -WindowStyle Hidden
        Start-Sleep -Seconds $DockerWaitSeconds
        docker compose up -d *> $null
        if ($LASTEXITCODE -eq 0) {
            Write-KeepAliveLog "compose stack ensured after Docker Desktop start"
        } else {
            Write-KeepAliveLog "docker compose retry failed with exit code $LASTEXITCODE"
        }
    }
}
