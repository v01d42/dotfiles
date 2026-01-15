# oh-my-zsh configuration
# (Named zinit.zsh for compatibility with home.nix, but uses oh-my-zsh)

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme (visual appearance handled by p10k, this is fallback)
ZSH_THEME="agnoster"

# Plugins
plugins=(git)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

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
