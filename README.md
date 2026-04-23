# wconfig — cross-platform config (geohot-style)

Repo-first setup where config files live directly in source control, similar to `geohot/configuration`. Windows (PowerShell + Windows Terminal) and macOS (zsh + Ghostty) share the same Starship prompt.

## Tracked layout

Shared:
- `configuration/.config/starship.toml` — Catppuccin Mocha powerline prompt

Windows:
- `configuration/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`
- `configuration/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`
- `configuration/WindowsTerminal/settings.json`
- `configuration/bin/home.ps1`

macOS:
- `configuration/.zshrc`
- `configuration/.zprofile`
- `configuration/.config/ghostty/config`

## Install on Windows

```powershell
pwsh -ExecutionPolicy Bypass -File .\install.ps1
```

Use `-NoBackup` to skip timestamped backup files.

### From GitHub (no clone)

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/winterrx/wconfig/master/bootstrap.ps1 -OutFile bootstrap.ps1
pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

## Install on macOS

Requires [Homebrew](https://brew.sh). The script installs `starship`, `zoxide`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and FiraCode Nerd Font, then drops dotfiles into `$HOME`.

```sh
./install.sh
```

Use `--no-backup` to skip timestamped backup files.

## Sync workflow

1. Edit your shell/terminal setup locally.
2. Run `extract.ps1` (Windows) or manually copy updated files into `configuration/` (macOS).
3. Commit and push.
4. Run `install.ps1` / `install.sh` on any new machine.
