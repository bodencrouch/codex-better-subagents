#!/usr/bin/env bash
# Install the routing guide and worker definitions into your home directory.
# Existing files that differ are backed up with a timestamped .bak suffix before being replaced.
set -euo pipefail

stamp="$(date +%Y%m%d-%H%M%S)"
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_file() {
  local from="$1" to="$2"
  mkdir -p "$(dirname "$to")"
  if [[ -e "$to" ]] && ! cmp -s "$from" "$to"; then
    cp "$to" "$to.bak.$stamp"
    echo "backed up $to -> $to.bak.$stamp"
  fi
  cp "$from" "$to"
  echo "installed $to"
}

install_file "$src/ROUTING.md" "$HOME/.agents/rules/subagent-model-routing.md"
for f in "$src"/agents/claude/*.md; do
  install_file "$f" "$HOME/.claude/agents/$(basename "$f")"
done
for f in "$src"/agents/codex/*.toml; do
  install_file "$f" "$HOME/.codex/agents/$(basename "$f")"
done
install_file "$src/codex/worker.config.toml" "$HOME/.codex/worker.config.toml"

echo
echo "Done. Point your AGENTS.md or CLAUDE.md at ~/.agents/rules/subagent-model-routing.md."
