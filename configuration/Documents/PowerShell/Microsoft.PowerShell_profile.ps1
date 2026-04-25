$profileStart = Get-Date

# Terminal home - cd to saved directory on startup
$terminalHomeFile = "$env:USERPROFILE\.terminal-home"
if (Test-Path $terminalHomeFile) {
    $terminalHome = (Get-Content $terminalHomeFile -Raw).Trim()
    $resolvedTerminalHome = [Environment]::ExpandEnvironmentVariables($terminalHome)
    if ($resolvedTerminalHome -and (Test-Path $resolvedTerminalHome)) {
        Set-Location $resolvedTerminalHome
    }
}

Set-PSReadlineKeyHandler -Key "Escape" -Function AcceptSuggestion

# Use Catppuccin Powerline preset
$configPath = "$env:USERPROFILE\.config\starship.toml"
if ((Get-Command starship -ErrorAction SilentlyContinue)) {
    New-Item -Path (Split-Path $configPath) -ItemType Directory -Force | Out-Null
    starship preset catppuccin-powerline -o $configPath
    Invoke-Expression (&starship init powershell)
}

$profileEnd = Get-Date
Write-Host "Profile loaded in $([math]::Round(($profileEnd - $profileStart).TotalMilliseconds))ms with $randomPreset preset" -ForegroundColor Green
# Lazy load Chocolatey profile only when choco command is used
function choco {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path $ChocolateyProfile) {
        Import-Module $ChocolateyProfile -Force
        Remove-Item Function:\choco
    }
    & choco @args
}

function nrd { npm run dev }
function nrs { npm run start }
function nrb { npm run build }
function brd { bun run dev }
function brs { bun run start }
function brb { bun run build }
function pushdb { npx prisma db push }
function newdb { npx prisma generate db }
function cc { claude --dangerously-skip-permissions @args }
function cod { codex --yolo @args }
function oc { opencode }
function home { & "$env:USERPROFILE\bin\home.ps1" @args }
function x3000 { netstat -ano | findstr :3000 | ForEach-Object { if ($_ -match 'LISTENING.*?(\d+)$') { taskkill /PID $matches[1] /F } } }
function rmrf { cmd /c "rmdir /s /q $args" 2>$null; if (Test-Path $args) { rm $args -r -fo } }
function cpwd { $p = $PWD.Path; Write-Output $p; $p | Set-Clipboard }
function list-aliases {
    $aliases = @{
        "nrd" = "npm run dev"
        "nrs" = "npm run start"
        "nrb" = "npm run build"
        "brd" = "bun run dev"
        "brs" = "bun run start"
        "brb" = "bun run build"
        "pushdb" = "npx prisma db push"
        "newdb" = "npx prisma generate db"
	"la" = "list-aliases"
	"cc" = "claude --dangerously-skip-permissions"
	"cod" = "codex --yolo"
	"x3000" = "kill process on port 3000"
	"rmrf" = "force delete (rm -rf)"
	"cpwd" = "print pwd and copy to clipboard"
	"home" = "set/get terminal start directory"
    }
    $aliases.GetEnumerator() | Sort-Object Name | Format-Table Name,Value -AutoSize
}
Set-Alias la list-aliases

# ctrl + shift + s cwd
Set-PSReadlineKeyHandler -Key "Ctrl+Shift+s" -ScriptBlock {
    $currentDir = $PWD.Path
    wt -w 0 nt -d "$currentDir" pwsh -NoExit
}

# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-PSReadlineKeyHandler -Key "Ctrl+Shift+c" -ScriptBlock {
    # Get current directory
    $currentDir = $PWD.Path
    # Open new tab in Windows Terminal at current directory and run Claude dangerously
    wt -w 0 nt -d "$currentDir" pwsh -NoExit -Command "claude --dangerously-skip-permissions"
}
