[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$configurationRoot = Join-Path $scriptRoot "configuration"

function Resolve-FirstExistingPath {
    param([string[]]$Candidates)

    foreach ($candidate in $Candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $null
}

function Export-File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string[]]$SourceCandidates,
        [Parameter(Mandatory = $true)]
        [string]$DestinationRelativePath
    )

    $sourcePath = Resolve-FirstExistingPath -Candidates $SourceCandidates
    if (-not $sourcePath) {
        Write-Warning "Skipped ${Name}: source file not found."
        return [PSCustomObject]@{
            name = $Name
            status = "missing"
            source = $null
            destination = $DestinationRelativePath
        }
    }

    $destinationPath = Join-Path $configurationRoot $DestinationRelativePath
    $destinationDirectory = Split-Path -Parent $destinationPath
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null

    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
    Write-Host "Exported $Name" -ForegroundColor Green

    return [PSCustomObject]@{
        name = $Name
        status = "exported"
        source = $sourcePath
        destination = $DestinationRelativePath
    }
}

$exportPlan = @(
    @{
        Name = "PowerShell profile (pwsh)"
        SourceCandidates = @("$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1")
        DestinationRelativePath = "Documents/PowerShell/Microsoft.PowerShell_profile.ps1"
    }
    @{
        Name = "Windows PowerShell profile"
        SourceCandidates = @("$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
        DestinationRelativePath = "Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"
    }
    @{
        Name = "Windows Terminal settings"
        SourceCandidates = @(
            "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
            "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
            "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
        )
        DestinationRelativePath = "WindowsTerminal/settings.json"
    }
    @{
        Name = "Starship config"
        SourceCandidates = @("$HOME\.config\starship.toml")
        DestinationRelativePath = ".config/starship.toml"
    }
    @{
        Name = "Terminal home helper script"
        SourceCandidates = @("$HOME\bin\home.ps1")
        DestinationRelativePath = "bin/home.ps1"
    }
)

$results = foreach ($item in $exportPlan) {
    Export-File -Name $item.Name -SourceCandidates $item.SourceCandidates -DestinationRelativePath $item.DestinationRelativePath
}

$exportedCount = @($results | Where-Object { $_.status -eq "exported" }).Count
$missingCount = @($results | Where-Object { $_.status -eq "missing" }).Count

Write-Host ""
Write-Host "Export complete." -ForegroundColor Cyan
Write-Host "Exported: $exportedCount"
Write-Host "Missing: $missingCount"
Write-Host "Destination: $configurationRoot"
