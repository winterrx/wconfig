[CmdletBinding()]
param(
    [string]$Repository = "winterrx/wconfig",
    [string]$Branch = "master",
    [string]$DotfilesSubPath = "dotfiles/windows",
    [switch]$NoBackup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Repository -notmatch "^[^/]+/[^/]+$") {
    throw "Repository must be in the format 'owner/repo'."
}

$tempRoot = Join-Path $env:TEMP ("win-config-" + [guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tempRoot "repo.zip"
$zipUrl = "https://github.com/$Repository/archive/refs/heads/$Branch.zip"

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    Write-Host "Downloading $zipUrl" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

    Write-Host "Extracting repository archive" -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

    $repoName = ($Repository -split "/")[-1]
    $repoRoot = Join-Path $tempRoot "$repoName-$Branch"
    if (-not (Test-Path -LiteralPath $repoRoot)) {
        throw "Could not locate extracted repo at $repoRoot"
    }

    $dotfilesRoot = Join-Path $repoRoot $DotfilesSubPath
    $installScriptPath = Join-Path $dotfilesRoot "install.ps1"
    if (-not (Test-Path -LiteralPath $installScriptPath)) {
        throw "Could not find install script at $installScriptPath"
    }

    $installParams = @{}
    if ($NoBackup) {
        $installParams.NoBackup = $true
    }

    & $installScriptPath @installParams
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
