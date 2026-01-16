#!/usr/bin/env zsh
# shellcheck disable=all

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME"/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Theme (visual appearance handled by p10k, this is fallback)
ZSH_THEME="agnoster"

# Plugins
plugins=(git)

# direnv hook (if not already loaded by home-manager)
if [[ -z "$DIRENV_DIR" ]] && command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# mise (if available)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# kubectl completion (if available)
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
  alias k=kubectl
fi
