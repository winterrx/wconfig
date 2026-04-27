#!/usr/bin/env bash
# macOS installer — mirrors install.ps1 for the mac side.
# Copies files from configuration/ to $HOME, with timestamped .bak backups.
# Usage: ./install.sh [--no-backup]

set -euo pipefail

NO_BACKUP=0
for arg in "$@"; do
  case "$arg" in
    --no-backup) NO_BACKUP=1 ;;
    -h|--help)
      echo "Usage: $0 [--no-backup]"
      exit 0
      ;;
    *) echo "unknown arg: $arg" >&2; exit 1 ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "install.sh targets macOS. Use install.ps1 on Windows." >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_root="$script_dir/configuration"

if [[ ! -d "$config_root" ]]; then
  echo "Missing $config_root." >&2
  exit 1
fi

install_file() {
  local name="$1" src_rel="$2" dest="$3"
  local src="$config_root/$src_rel"
  if [[ ! -f "$src" ]]; then
    echo "skip $name: $src_rel not in configuration/"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ $NO_BACKUP -eq 0 && -e "$dest" ]]; then
    local ts backup
    ts="$(date +%Y%m%d-%H%M%S)"
    backup="$dest.bak-$ts"
    cp "$dest" "$backup"
    echo "backup $name -> $backup"
  fi
  cp "$src" "$dest"
  echo "install $name -> $dest"
}

# ---- deps ----
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install from https://brew.sh first." >&2
  exit 1
fi

missing_formulae=()
for f in starship zoxide zsh-autosuggestions zsh-syntax-highlighting fzf; do
  brew list --formula "$f" >/dev/null 2>&1 || missing_formulae+=("$f")
done
if (( ${#missing_formulae[@]} )); then
  echo "installing: ${missing_formulae[*]}"
  brew install "${missing_formulae[@]}"
fi

if ! brew list --cask font-fira-code-nerd-font >/dev/null 2>&1; then
  brew install --cask font-fira-code-nerd-font
fi

# Generate ~/.fzf.zsh (keybindings + completion) without touching .zshrc —
# wconfig already sources it from the tracked .zshrc.
if [[ ! -f "$HOME/.fzf.zsh" ]]; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc >/dev/null
fi

# ---- dotfiles ----
install_file "zshrc"         ".zshrc"                  "$HOME/.zshrc"
install_file "zprofile"      ".zprofile"               "$HOME/.zprofile"
install_file "starship"      ".config/starship.toml"   "$HOME/.config/starship.toml"
install_file "ghostty"       ".config/ghostty/config"  "$HOME/.config/ghostty/config"
install_file "zed settings"  ".config/zed/settings.json" "$HOME/.config/zed/settings.json"
install_file "zed keymap"    ".config/zed/keymap.json"   "$HOME/.config/zed/keymap.json"

# ---- macOS defaults ----
bash "$config_root/bin/macos-defaults.sh"

echo
echo "done. restart Ghostty (⌘Q + reopen) to pick up the font + theme."
