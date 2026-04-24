#!/usr/bin/env bash
# macOS system defaults applied by install.sh. Idempotent — safe to re-run.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

echo "applying macOS defaults..."

# Fast key repeat (below the System Settings UI minimum).
# Units are 15ms; the UI floors at KeyRepeat=2 / InitialKeyRepeat=15.
# Takes effect after logout/login.
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 10

echo "macOS defaults applied. log out + back in for key repeat to take effect."
