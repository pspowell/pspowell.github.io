#!/usr/bin/env bash
# wsl-bootstrap.sh: the Linux side of "Power-user WSL setup from scratch".
# https://pspowell.github.io/2026/11/14/power-user-wsl-setup-from-scratch.html
#
# Run inside Ubuntu on WSL as your normal user (not root):
#   bash wsl-bootstrap.sh --git-name "Your Name" --git-email you@example.com
#
# Options:
#   --git-name NAME      Git user.name   (env: BOOT_GIT_NAME)
#   --git-email EMAIL    Git user.email, also the SSH key comment (env: BOOT_GIT_EMAIL)
#   --zsh                Make zsh the login shell (env: BOOT_ZSH=1)
#   --no-node            Skip nvm + Node LTS (env: BOOT_NO_NODE=1)
#   --no-gui             Skip the WSLg GUI apps (env: BOOT_NO_GUI=1)
#   --no-ssh             Skip SSH key + config (env: BOOT_NO_SSH=1)
#   --no-passphrase      Create the SSH key without a passphrase (env: BOOT_NO_PASSPHRASE=1)
#   --github             Install gh, sign in, and upload the SSH key (env: BOOT_GITHUB=1)
#
# Safe to re-run: each step checks what is already done. Existing dotfiles that
# would be replaced are backed up as <file>.bak-<timestamp>.
set -euo pipefail

NVM_VERSION="${NVM_VERSION:-v0.39.7}"
APT_OPTS=(-y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)
STAMP="$(date +%Y%m%d-%H%M%S)"

GIT_NAME="${BOOT_GIT_NAME:-}"
GIT_EMAIL="${BOOT_GIT_EMAIL:-}"
DO_ZSH="${BOOT_ZSH:-0}"
NO_NODE="${BOOT_NO_NODE:-0}"
NO_GUI="${BOOT_NO_GUI:-0}"
NO_SSH="${BOOT_NO_SSH:-0}"
NO_PASSPHRASE="${BOOT_NO_PASSPHRASE:-0}"
DO_GITHUB="${BOOT_GITHUB:-0}"

while [ $# -gt 0 ]; do
  case "$1" in
    --git-name)      GIT_NAME="$2"; shift 2 ;;
    --git-email)     GIT_EMAIL="$2"; shift 2 ;;
    --zsh)           DO_ZSH=1; shift ;;
    --no-node)       NO_NODE=1; shift ;;
    --no-gui)        NO_GUI=1; shift ;;
    --no-ssh)        NO_SSH=1; shift ;;
    --no-passphrase) NO_PASSPHRASE=1; shift ;;
    --github)        DO_GITHUB=1; shift ;;
    -h|--help)       sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

say()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
note() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m    ! %s\033[0m\n' "$*"; }
is_tty() { [ -t 0 ] && [ -t 1 ]; }

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your normal user, not root (it uses sudo where needed)." >&2
  exit 1
fi

# Write a file, backing up an existing one only if its content differs.
write_file() {  # write_file <path>  (content on stdin)
  local path="$1" tmp
  tmp="$(mktemp)"
  cat > "$tmp"
  mkdir -p "$(dirname "$path")"
  if [ -f "$path" ] && cmp -s "$tmp" "$path"; then
    rm -f "$tmp"; note "$path already up to date"; return
  fi
  if [ -f "$path" ]; then cp "$path" "$path.bak-$STAMP"; note "backed up $path"; fi
  mv "$tmp" "$path"; note "wrote $path"
}

# Replace (or add) a marked block in a file.
put_block() {  # put_block <file>  (block content on stdin)
  local file="$1" begin="# >>> wsl-bootstrap >>>" end="# <<< wsl-bootstrap <<<" body
  body="$(cat)"
  touch "$file"
  if grep -qF "$begin" "$file"; then
    sed -i "\|$begin|,\|$end|d" "$file"
  fi
  printf '\n%s\n%s\n%s\n' "$begin" "$body" "$end" >> "$file"
  note "updated block in $file"
}

# --- Update + core packages -------------------------------------------------
say "Updating Ubuntu (enter your Ubuntu password if asked)"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade "${APT_OPTS[@]}"

say "Installing core packages"
PKGS=(build-essential git curl wget unzip zip ca-certificates gnupg
      software-properties-common htop btop tree jq ripgrep fd-find fzf
      neovim vim tmux python3 zsh x11-apps openssh-client)
[ "$NO_GUI" = 1 ] || PKGS+=(xfce4-terminal thunar file-roller mousepad gedit gir1.2-peas-1.0)
[ "$DO_GITHUB" = 1 ] && PKGS+=(gh)
sudo DEBIAN_FRONTEND=noninteractive apt-get install "${APT_OPTS[@]}" "${PKGS[@]}"

# --- Directories --------------------------------------------------------------
say "Creating ~/projects, ~/bin, ~/.local/bin"
mkdir -p "$HOME/projects" "$HOME/bin" "$HOME/.local/bin"

# --- /etc/wsl.conf ---------------------------------------------------------------
say "Writing /etc/wsl.conf"
SYSTEMD_LINE=""
if [ -f /etc/wsl.conf ] && grep -Eq '^[[:space:]]*systemd[[:space:]]*=[[:space:]]*true' /etc/wsl.conf; then
  SYSTEMD_LINE="systemd = true"   # keep Ubuntu's default if it was on
fi
WSL_CONF="$(mktemp)"
{
  if [ -n "$SYSTEMD_LINE" ]; then printf '[boot]\n%s\n\n' "$SYSTEMD_LINE"; fi
  printf '[user]\ndefault = %s\n\n' "$(id -un)"
  cat <<'EOF'
[automount]
options = "metadata"

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true
EOF
} > "$WSL_CONF"
if [ -f /etc/wsl.conf ] && cmp -s "$WSL_CONF" /etc/wsl.conf; then
  note "/etc/wsl.conf already up to date"
else
  [ -f /etc/wsl.conf ] && sudo cp /etc/wsl.conf "/etc/wsl.conf.bak-$STAMP"
  sudo install -m 644 "$WSL_CONF" /etc/wsl.conf
  note "wrote /etc/wsl.conf (takes effect after 'wsl --shutdown' from Windows)"
fi
rm -f "$WSL_CONF"

# --- Shell setup --------------------------------------------------------------
say "Adding aliases and editor settings to your shell"
SHELL_BLOCK="$(cat <<'EOF'
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias v='nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias cls='clear'

export EDITOR=nvim
export VISUAL=nvim

if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
  alias ls='ls --color=auto'
fi
EOF
)"
printf '%s\n' "$SHELL_BLOCK" | put_block "$HOME/.bashrc"
if [ "$DO_ZSH" = 1 ]; then
  printf '%s\n' "$SHELL_BLOCK" | put_block "$HOME/.zshrc"
  if [ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "/usr/bin/zsh" ]; then
    sudo chsh -s /usr/bin/zsh "$(id -un)"
    note "login shell is now zsh (new terminals only)"
  fi
fi

# --- uv + Python tools --------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
  say "Installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
else
  say "Updating uv"
  uv self update || warn "uv self update failed (fine if uv came from another installer)"
fi
note "$(uv --version)"

say "Installing ruff, black, httpie with uv tool"
for t in ruff black httpie; do
  if uv tool list 2>/dev/null | grep -q "^$t "; then
    note "$t already installed"
  else
    uv tool install "$t"
  fi
done
uv tool upgrade --all
uv tool update-shell >/dev/null 2>&1 || true

# --- Git ----------------------------------------------------------------------------
say "Configuring Git"
[ -z "$GIT_NAME" ]  && GIT_NAME="$(git config --global user.name  || true)"
[ -z "$GIT_EMAIL" ] && GIT_EMAIL="$(git config --global user.email || true)"
if is_tty; then
  [ -z "$GIT_NAME" ]  && read -r -p "    Git name (e.g. Jane Smith): " GIT_NAME
  [ -z "$GIT_EMAIL" ] && read -r -p "    Git email: " GIT_EMAIL
fi
if [ -n "$GIT_NAME" ];  then git config --global user.name  "$GIT_NAME";  fi
if [ -n "$GIT_EMAIL" ]; then git config --global user.email "$GIT_EMAIL"; fi
[ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ] && warn "Git name/email not set; rerun with --git-name and --git-email"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor nvim
git config --global color.ui auto
git config --global core.autocrlf input
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.lg "log --oneline --graph --decorate --all"
note "done"

# --- SSH ------------------------------------------------------------------------------
if [ "$NO_SSH" != 1 ]; then
  say "Setting up SSH"
  mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
  KEY="$HOME/.ssh/id_ed25519"
  if [ -f "$KEY" ]; then
    note "$KEY already exists, keeping it"
  else
    COMMENT="${GIT_EMAIL:-$(id -un)@$(hostname)}"
    if [ "$NO_PASSPHRASE" = 1 ] || ! is_tty; then
      ssh-keygen -t ed25519 -C "$COMMENT" -f "$KEY" -N ""
    else
      note "Choose a passphrase for the key (or press Enter twice for none)"
      ssh-keygen -t ed25519 -C "$COMMENT" -f "$KEY"
    fi
  fi
  if ! grep -qE '^[[:space:]]*Host[[:space:]]+github\.com' "$HOME/.ssh/config" 2>/dev/null; then
    cat >> "$HOME/.ssh/config" <<'EOF'

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
EOF
    note "added github.com to ~/.ssh/config"
  fi
  chmod 600 "$HOME/.ssh/config" "$KEY"
  chmod 644 "$KEY.pub"
fi

# --- GitHub (optional) ----------------------------------------------------------------
if [ "$DO_GITHUB" = 1 ] && [ "$NO_SSH" != 1 ]; then
  say "Uploading your SSH key to GitHub"
  if ! gh auth status -h github.com >/dev/null 2>&1; then
    note "Sign in: choose 'Login with a web browser' and paste the code at github.com/login/device"
    gh auth login -h github.com -p ssh --web --skip-ssh-key -s admin:public_key
  fi
  if gh ssh-key list 2>/dev/null | grep -qF "$(cut -d' ' -f2 "$HOME/.ssh/id_ed25519.pub")"; then
    note "key already on GitHub"
  else
    gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "WSL $(hostname)" \
      || { gh auth refresh -h github.com -s admin:public_key && \
           gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "WSL $(hostname)"; }
  fi
  ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | head -1 || true
fi

# --- Node via nvm (optional) ------------------------------------------------------------
if [ "$NO_NODE" != 1 ]; then
  say "Installing Node.js LTS with nvm"
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
  fi
  set +u
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*' >/dev/null
  note "node $(node --version), npm $(npm --version)"
  set -u
fi

# --- Editor + tmux ---------------------------------------------------------------------
say "Writing editor and tmux config"
VIMRC="$(cat <<'EOF'
set number
set relativenumber
set expandtab
set shiftwidth=4
set tabstop=4
set smartindent
set ignorecase
set smartcase
set incsearch
set hlsearch
set clipboard=unnamedplus
EOF
)"
printf '%s\n' "$VIMRC" | write_file "$HOME/.vimrc"
printf '%s\n' "$VIMRC" | write_file "$HOME/.config/nvim/init.vim"
write_file "$HOME/.tmux.conf" <<'EOF'
set -g mouse on
set -g history-limit 100000
setw -g mode-keys vi
set -g default-terminal "screen-256color"
EOF

# --- Done ------------------------------------------------------------------------------
say "All done"
note "Close this terminal, run 'wsl --shutdown' in PowerShell, then open Ubuntu again."
if [ "$NO_SSH" != 1 ] && [ "$DO_GITHUB" != 1 ]; then
  note "Your public SSH key (add it to GitHub, GitLab or your servers):"
  printf '\n%s\n' "$(cat "$HOME/.ssh/id_ed25519.pub")"
fi
