<#
.SYNOPSIS
    Set or get the default terminal starting directory.
.DESCRIPTION
    When you open a new terminal, it will automatically cd to this directory.
.EXAMPLE
    home .         # Set current directory as terminal home
    home C:\Code   # Set specific path as terminal home
    home           # Show current terminal home
    home -Clear    # Clear terminal home (use default)
    home -c        # Clear (short form)
#>

param(
    [Parameter(Position = 0)]
    [string]$Path,
    [Alias("c")]
    [switch]$Clear
)

$configFile = "$env:USERPROFILE\.terminal-home"

function Convert-ToPortableUserPath {
    param([string]$ResolvedPath)

    $userProfile = [Environment]::GetFolderPath("UserProfile")
    if ($ResolvedPath.StartsWith($userProfile, [System.StringComparison]::OrdinalIgnoreCase)) {
        return "%USERPROFILE%" + $ResolvedPath.Substring($userProfile.Length)
    }

    return $ResolvedPath
}

function Set-TerminalHome {
    param([string]$Dir)
    
    $resolvedPath = Resolve-Path $Dir -ErrorAction SilentlyContinue
    if (-not $resolvedPath) {
        Write-Host "Error: Path '$Dir' does not exist" -ForegroundColor Red
        return
    }
    
    $portablePath = Convert-ToPortableUserPath -ResolvedPath $resolvedPath.Path
    $portablePath | Out-File -FilePath $configFile -Encoding UTF8 -NoNewline
    Write-Host "Terminal home set to: " -NoNewline
    Write-Host $portablePath -ForegroundColor Cyan
}

function Get-TerminalHome {
    if (Test-Path $configFile) {
        $saved = (Get-Content $configFile -Raw).Trim()
        $expanded = [Environment]::ExpandEnvironmentVariables($saved)
        Write-Host "Terminal home: " -NoNewline
        Write-Host $expanded -ForegroundColor Cyan
    } else {
        Write-Host "No terminal home set (using default)" -ForegroundColor Yellow
    }
}

function Clear-TerminalHome {
    if (Test-Path $configFile) {
        Remove-Item $configFile -Force
        Write-Host "Terminal home cleared" -ForegroundColor Green
    } else {
        Write-Host "No terminal home was set" -ForegroundColor Yellow
    }
}

# Main logic
if ($Clear) {
    Clear-TerminalHome
} elseif ($Path -eq "") {
    Get-TerminalHome
} elseif ($Path -eq ".") {
    Set-TerminalHome -Dir $PWD.Path
} else {
    Set-TerminalHome -Dir $Path
}
