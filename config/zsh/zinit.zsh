#!/usr/bin/env zsh
# shellcheck disable=all

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME"/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinit Plugins
# theme
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure
# auto-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# direnv hook (if not already loaded by home-manager)
if [[ -z "$DIRENV_DIR" ]] && command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
  # Override to use PATH direnv instead of the hardcoded nix store path,
  # so sessions survive nix GC removing the old store path.
  _direnv_hook() {
    trap -- '' SIGINT
    eval "$(direnv export zsh)"
    trap - SIGINT
  }
fi

# Initialize completion system
autoload -Uz compinit && compinit

# install zeno.zsh
# zinit の emulate スコープ下では zeno.zsh 後半 (deno バージョン判定周り) が
# 完走せず ZENO_LOADED が set されない環境があるため、clone/update は zinit に
# 任せ、初期化はネイティブ shell 上で再 source して完走させる。
zinit ice lucid depth"1" blockf
zinit light yuki-yano/zeno.zsh
[[ -z "${ZENO_LOADED}" ]] && source "${ZINIT[PLUGINS_DIR]}/yuki-yano---zeno.zsh/zeno.zsh"

if [[ -n "${ZENO_LOADED}" ]]; then
  bindkey " "  zeno-auto-snippet
  bindkey "^m" zeno-auto-snippet-and-accept-line
  bindkey "^i" zeno-completion
  bindkey "^g" zeno-ghq-cd
  bindkey "^r" zeno-history-selection
  bindkey "^x^i" zeno-insert-snippet
fi

# kubectl completion (if available)
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
  alias k=kubectl
fi
