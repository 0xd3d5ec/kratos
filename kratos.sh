#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="kalix"
VERSION="0.1"
AUTHOR="Bl4ckan0n"
RED="\033[0;31m"
RESET="\033[0m"

info() {
  printf "[*] %s\n" "$1"
}

success() {
  printf "[+] %s\n" "$1"
}

fail() {
  printf "[x] %s\n" "$1"
}

on_error() {
  fail "An error has occurred. Exiting."
}

trap on_error ERR

printf "%b\n" "${RED}██╗  ██╗ █████╗ ██╗     ██╗██╗  ██╗      ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗"
printf "%b\n" "██║ ██╔╝██╔══██╗██║     ██║╚██╗██╔╝      ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝"
printf "%b\n" "█████╔╝ ███████║██║     ██║ ╚███╔╝ █████╗███████╗██║     ██████╔╝██║██████╔╝   ██║   "
printf "%b\n" "██╔═██╗ ██╔══██║██║     ██║ ██╔██╗ ╚════╝╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   "
printf "%b\n" "██║  ██╗██║  ██║███████╗██║██╔╝ ██╗      ███████║╚██████╗██║  ██║██║██║        ██║   "
printf "%b\n" "╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝      ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ${RESET}"
printf "%s\n" ""
printf "%s\n" "${SCRIPT_NAME} v${VERSION} by ${AUTHOR}"
printf "%s\n" ""

if [ "${EUID}" -eq 0 ]; then
  fail "Do not run this script as root. It will use sudo when needed."
  exit 1
fi

ensure_pkg() {
  if ! dpkg -s "$1" >/dev/null 2>&1; then
    sudo apt-get install -y "$1"
  fi
}

backup_file() {
  if [ -f "$1" ]; then
    info "Backing up $1"
    cp "$1" "$1.kalix.bak"
  fi
}

info "Updating package lists"
sudo apt-get update
success "Package lists updated"

info "Installing base packages"
ensure_pkg git
ensure_pkg curl
ensure_pkg zsh
ensure_pkg tmux
ensure_pkg fzf
ensure_pkg nala
ensure_pkg xclip
success "Base packages installed"

if ! command -v zoxide >/dev/null 2>&1; then
  info "Installing zoxide"
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  success "Zoxide setup completed"
else
  success "Zoxide already installed"
fi

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
if [ ! -d "$ZSH_DIR" ]; then
  info "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh-my-zsh setup completed"
else
  success "Oh-my-zsh already installed"
fi

THEME_DIR="$ZSH_DIR/custom/themes"
KALI_THEME_DIR="$THEME_DIR/kali-like-zsh-theme"

if [ ! -d "$KALI_THEME_DIR" ]; then
  info "Installing kali-like zsh theme"
  git clone https://github.com/clamy54/kali-like-zsh-theme "$KALI_THEME_DIR"
fi

KALI_THEME_FILE="$KALI_THEME_DIR/kali-like.zsh-theme"
if [ -f "$KALI_THEME_FILE" ]; then
  info "Configuring kali-like theme (twoline prompt only)"
  cp "$KALI_THEME_FILE" "$KALI_THEME_FILE.bak"
  sed -i "/^PROMPT=\"\$oneline_prompt\"/ s/^/# /" "$KALI_THEME_FILE"
  sed -i "/^PROMPT=\"\$twoline_prompt\"/ s/^# //" "$KALI_THEME_FILE"
  success "Kali-like theme setup completed"
else
  fail "Kali-like theme file not found"
fi

TMUX_REPO_DIR="$HOME/.tmux"
if [ ! -d "$TMUX_REPO_DIR" ]; then
  info "Installing .tmux config"
  git clone https://github.com/gpakosz/.tmux "$TMUX_REPO_DIR"
  backup_file "$HOME/.tmux.conf"
  ln -s -f "$TMUX_REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
  if [ ! -f "$HOME/.tmux.conf.local" ]; then
    cp "$TMUX_REPO_DIR/.tmux.conf.local" "$HOME/.tmux.conf.local"
  fi
  success "Tmux setup completed"
else
  success "Tmux already configured"
fi

if [ -f "$HOME/.tmux.conf.local" ]; then
  backup_file "$HOME/.tmux.conf.local"
  if ! grep -q "KALIX_LOGGING" "$HOME/.tmux.conf.local"; then
    info "Configuring tmux logging defaults"
    cat <<'EOF' >> "$HOME/.tmux.conf.local"

# KALIX_LOGGING
set -g @kalix_log_dir "$HOME/tmux-logs"
set -g @kalix_log_file "#{@kalix_log_dir}/tmux-#{session_name}-#{window_index}-#{pane_index}-%Y%m%d-%H%M%S.log"
run-shell -b 'mkdir -p "#{@kalix_log_dir}"'
bind-key L pipe-pane -o -t 0 "cat >> #{@kalix_log_file}"
EOF
    success "Tmux logging setup completed"
  else
    success "Tmux logging defaults already configured"
  fi

  if ! grep -q "KALIX_DEFAULTS" "$HOME/.tmux.conf.local"; then
    info "Configuring tmux defaults"
    cat <<'EOF' >> "$HOME/.tmux.conf.local"

# KALIX_DEFAULTS
set -g mouse on
set -g history-limit 20000
set -g status-position top
setw -g mode-keys vi
unbind C-b
set -g prefix C-s
bind C-s send-prefix
EOF
    success "Tmux defaults configured"
  else
    success "Tmux defaults already configured"
  fi

  if ! grep -q "KALIX_CLIPBOARD" "$HOME/.tmux.conf.local"; then
    info "Enabling tmux OS clipboard integration"
    cat <<'EOF' >> "$HOME/.tmux.conf.local"

# KALIX_CLIPBOARD
set -g set-clipboard on
tmux_conf_copy_to_os_clipboard=true
EOF
    success "Tmux OS clipboard integration configured"
  else
    success "Tmux OS clipboard integration already configured"
  fi
fi

ZSHRC="$HOME/.zshrc"
if [ ! -f "$ZSHRC" ]; then
  info "Creating .zshrc"
  cat <<EOF > "$ZSHRC"
export ZSH="$ZSH_DIR"
ZSH_THEME="kali-like"
plugins=(git z fzf zsh-autosuggestions zsh-syntax-highlighting)
source "\$ZSH/oh-my-zsh.sh"
EOF
fi

if [ -f "$ZSHRC" ]; then
  backup_file "$ZSHRC"
  if ! grep -q "oh-my-zsh.sh" "$ZSHRC"; then
    info "Loading oh-my-zsh"
    cat <<EOF >> "$ZSHRC"

export ZSH="$ZSH_DIR"
ZSH_THEME="kali-like"
plugins=(git z fzf zsh-autosuggestions zsh-syntax-highlighting)
source "\$ZSH/oh-my-zsh.sh"
EOF
  fi

  if ! grep -q "kali-like" "$ZSHRC"; then
    info "Setting ZSH theme"
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"kali-like\"/" "$ZSHRC" || true
    if ! grep -q "^ZSH_THEME=" "$ZSHRC"; then
      if grep -q "oh-my-zsh.sh" "$ZSHRC"; then
        sed -i "/oh-my-zsh.sh/i ZSH_THEME=\"kali-like\"" "$ZSHRC"
      else
        printf "\nZSH_THEME=\"kali-like\"\n" >> "$ZSHRC"
      fi
    fi
  fi

  if ! grep -q "KALIX_ZOXIDE" "$ZSHRC" && ! grep -q "zoxide init zsh" "$ZSHRC"; then
    info "Enabling zoxide"
    cat <<'EOF' >> "$ZSHRC"

# KALIX_ZOXIDE
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
EOF
  fi

  if ! grep -q "KALIX_PLUGINS" "$ZSHRC"; then
    info "Configuring ZSH plugins"
    sed -i "s/^plugins=(.*)/plugins=(git z fzf zsh-autosuggestions zsh-syntax-highlighting)/" "$ZSHRC" || true
    if ! grep -q "^plugins=" "$ZSHRC"; then
      if grep -q "oh-my-zsh.sh" "$ZSHRC"; then
        sed -i "/oh-my-zsh.sh/i plugins=(git z fzf zsh-autosuggestions zsh-syntax-highlighting)" "$ZSHRC"
      else
        printf "\nplugins=(git z fzf zsh-autosuggestions zsh-syntax-highlighting)\n" >> "$ZSHRC"
      fi
    fi
    printf "\n# KALIX_PLUGINS\n" >> "$ZSHRC"
  fi

  if ! grep -q "alias apt=\"sudo nala\"" "$ZSHRC"; then
    info "Adding nala alias"
    printf "\nalias apt=\"sudo nala\"\n" >> "$ZSHRC"
  fi

  if ! grep -q "tmux new-session" "$ZSHRC"; then
    info "Enabling tmux on new zsh sessions"
    cat <<'EOF' >> "$ZSHRC"

# Auto-start tmux
if command -v tmux >/dev/null 2>&1; then
  if [ -z "${TMUX-}" ] && [ -n "${PS1-}" ]; then
    tmux new-session -A -s main
  fi
fi
EOF
  fi
fi

info "Tmux logging setup instructions"
success "Tmux logging instructions: use 'tmux pipe-pane -o -t 0 \"cat >> ~/tmux-logs/\$(date +%F_%H%M%S).log\"' to start"

if [ "${SHELL}" != "$(command -v zsh)" ]; then
  info "Setting default shell to zsh"
  chsh -s "$(command -v zsh)"
fi

ZSH_CUSTOM="${ZSH_DIR}/custom"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  info "Installing zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  success "zsh-autosuggestions installed"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  info "Installing zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  success "zsh-syntax-highlighting installed"
fi

success "Done. Restart your terminal or run 'exec zsh'."
