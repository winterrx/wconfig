[CmdletBinding()]
param(
    [switch]$NoBackup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$configurationRoot = Join-Path $scriptRoot "configuration"

if (-not (Test-Path -LiteralPath $configurationRoot)) {
    throw "Missing $configurationRoot. Run extract.ps1 first or sync configuration from your repo."
}

function Resolve-InstallTargetPath {
    param([string[]]$Candidates)

    foreach ($candidate in $Candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $Candidates[0]
}

function Install-Dotfile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$SourceRelativePath,
        [Parameter(Mandatory = $true)]
        [string[]]$TargetCandidates
    )

    $sourcePath = Join-Path $configurationRoot $SourceRelativePath
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        Write-Warning "Skipped ${Name}: ${SourceRelativePath} not found in configuration directory."
        return
    }

    $targetPath = Resolve-InstallTargetPath -Candidates $TargetCandidates
    $targetDirectory = Split-Path -Parent $targetPath
    if ($targetDirectory) {
        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    }

    if ((-not $NoBackup) -and (Test-Path -LiteralPath $targetPath)) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupPath = "$targetPath.bak-$timestamp"
        Copy-Item -LiteralPath $targetPath -Destination $backupPath -Force
        Write-Host "Backed up $Name to $backupPath" -ForegroundColor Yellow
    }

    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
    Write-Host "Installed $Name -> $targetPath" -ForegroundColor Green
}

$installPlan = @(
    @{
        Name = "PowerShell profile (pwsh)"
        SourceRelativePath = "Documents/PowerShell/Microsoft.PowerShell_profile.ps1"
        TargetCandidates = @("$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1")
    }
    @{
        Name = "Windows PowerShell profile"
        SourceRelativePath = "Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"
        TargetCandidates = @("$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
    }
    @{
        Name = "Windows Terminal settings"
        SourceRelativePath = "WindowsTerminal/settings.json"
        TargetCandidates = @(
            "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
            "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
            "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
        )
    }
    @{
        Name = "Starship config"
        SourceRelativePath = ".config/starship.toml"
        TargetCandidates = @("$HOME\.config\starship.toml")
    }
    @{
        Name = "Terminal home helper script"
        SourceRelativePath = "bin/home.ps1"
        TargetCandidates = @("$HOME\bin\home.ps1")
    }
)

foreach ($item in $installPlan) {
    Install-Dotfile -Name $item.Name -SourceRelativePath $item.SourceRelativePath -TargetCandidates $item.TargetCandidates
}

Write-Host ""
Write-Host "Install complete. Restart Windows Terminal and PowerShell." -ForegroundColor Cyan
