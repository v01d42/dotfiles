#!/usr/bin/env bash
# PostToolUse hook: lints markdown edited via Edit/Write with textlint-rule-preset-ai-words-ja
# to catch AI-sounding Japanese phrasing right after writing.
# https://github.com/p1ass/textlint-rule-preset-ai-words-ja
set -euo pipefail

input="$(cat)"
file_path="$(jq -r '.tool_input.file_path // empty' <<<"$input")"

[ -n "$file_path" ] || exit 0
case "$file_path" in
*.md | *.mdx) ;;
*) exit 0 ;;
esac
[ -f "$file_path" ] || exit 0

command -v textlint >/dev/null 2>&1 || exit 0

# textlint-rule-preset-ai-words-ja is installed globally (nix-managed
# NPM_PACKAGES in nix/home.nix); make it resolvable from any cwd.
export NODE_PATH="$HOME/.local/lib/node_modules${NODE_PATH:+:$NODE_PATH}"

script_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
config="$script_dir/lint-ai-words.textlintrc.json"

if ! output="$(textlint --config "$config" "$file_path" 2>&1)"; then
  echo "$output" >&2
  exit 2
fi
exit 0
