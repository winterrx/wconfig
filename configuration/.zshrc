export PATH="$HOME/.local/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/jack/.lmstudio/bin"
# End of LM Studio CLI section

# ---- history ----
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE INC_APPEND_HISTORY

# ---- completion ----
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ---- plugins (installed via brew) ----
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Escape accepts the autosuggestion (wconfig parity)
bindkey '^[' autosuggest-accept

# ---- terminal home: cd to saved dir on new shells ----
TERMINAL_HOME_FILE="$HOME/.terminal-home"
if [[ -z "$TERMINAL_HOME_LOADED" && -f "$TERMINAL_HOME_FILE" && -o interactive ]]; then
  _th="$(tr -d '[:space:]' < "$TERMINAL_HOME_FILE")"
  _th="${_th/#\~/$HOME}"
  if [[ -d "$_th" && "$PWD" == "$HOME" ]]; then
    cd "$_th"
  fi
  export TERMINAL_HOME_LOADED=1
  unset _th
fi

home() {
  if [[ "$1" == "-c" || "$1" == "--clear" ]]; then
    [[ -f "$TERMINAL_HOME_FILE" ]] && rm "$TERMINAL_HOME_FILE" && echo "Terminal home cleared" || echo "No terminal home was set"
  elif [[ -z "$1" ]]; then
    [[ -f "$TERMINAL_HOME_FILE" ]] && echo "Terminal home: $(cat "$TERMINAL_HOME_FILE")" || echo "No terminal home set (using default)"
  elif [[ "$1" == "." ]]; then
    echo -n "$PWD" > "$TERMINAL_HOME_FILE" && echo "Terminal home set to: $PWD"
  else
    if [[ -d "$1" ]]; then
      echo -n "${1:A}" > "$TERMINAL_HOME_FILE" && echo "Terminal home set to: ${1:A}"
    else
      echo "Error: Path '$1' does not exist" >&2
    fi
  fi
}

# ---- aliases (wconfig parity) ----
alias nrd='npm run dev'
alias nrs='npm run start'
alias nrb='npm run build'
alias brd='bun run dev'
alias brs='bun run start'
alias brb='bun run build'
alias pushdb='npx prisma db push'
alias newdb='npx prisma generate db'
alias cc='claude'
alias ccd='claude --dangerously-skip-permissions'
alias cdx='codex'
alias cdxy='codex --yolo'
alias oc='opencode'
alias rmrf='rm -rf'
alias cpwd='pwd | tee /dev/tty | pbcopy'
alias sho='cat ~/.ssh/config'

x3000() {
  local pid
  pid=$(lsof -ti tcp:3000)
  [[ -n "$pid" ]] && kill -9 $pid && echo "killed $pid on :3000" || echo "nothing on :3000"
}

# ---- dmginstall: mount a .dmg, copy the .app to /Applications, eject ----
dmginstall() {
  local dmg="$1"
  [[ -f "$dmg" ]] || { echo "usage: dmginstall <file.dmg>"; return 1; }
  local mount_point
  mount_point=$(hdiutil attach -nobrowse -noautoopen "$dmg" | grep -Eo '/Volumes/[^ ]+.*' | tail -1)
  [[ -d "$mount_point" ]] || { echo "failed to mount $dmg"; return 1; }
  local app
  app=$(find "$mount_point" -maxdepth 2 -name "*.app" -print -quit)
  if [[ -z "$app" ]]; then
    echo "no .app found in $mount_point — ejecting"
    hdiutil detach "$mount_point" -quiet
    return 1
  fi
  echo "installing $(basename "$app")..."
  ditto "$app" "/Applications/$(basename "$app")" && echo "installed to /Applications/$(basename "$app")"
  hdiutil detach "$mount_point" -quiet && echo "ejected $mount_point"
}

list-aliases() {
  cat <<'EOF'
nrd      npm run dev
nrs      npm run start
nrb      npm run build
brd      bun run dev
brs      bun run start
brb      bun run build
pushdb   npx prisma db push
newdb    npx prisma generate db
cc       claude
ccd      claude --dangerously-skip-permissions
cdx      codex
cdxy     codex --yolo
oc       opencode
x3000    kill process on port 3000
rmrf     rm -rf
cpwd     print pwd and copy to clipboard
sho      print ~/.ssh/config
home     set/get terminal start directory
la       list-aliases
dmginstall <file.dmg>   mount .dmg, copy .app to /Applications, eject
EOF
}
alias la='list-aliases'

# ---- zoxide (smart cd) ----
eval "$(zoxide init zsh)"

# ---- starship prompt ----
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
