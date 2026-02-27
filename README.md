# Windows configuration (geohot-style)

This is a repo-first setup where config files live directly in source control, similar to `geohot/configuration`.

Tracked config layout:

- `configuration/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`
- `configuration/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`
- `configuration/WindowsTerminal/settings.json`
- `configuration/.config/starship.toml`
- `configuration/bin/home.ps1`

## Pull your current setup into this repo

```powershell
pwsh -ExecutionPolicy Bypass -File .\dotfiles\windows\extract.ps1
```

## Install from a local clone

```powershell
pwsh -ExecutionPolicy Bypass -File .\dotfiles\windows\install.ps1
```

Use `-NoBackup` to skip timestamped backup files.

## Install directly from GitHub (no clone)

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/winterrx/wconfig/master/dotfiles/windows/bootstrap.ps1 -OutFile bootstrap.ps1
pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

## Sync workflow

1. Edit your shell/terminal setup locally.
2. Run `extract.ps1` to refresh `configuration/`.
3. Commit and push.
4. Run `install.ps1` (or `bootstrap.ps1`) on any new machine.
