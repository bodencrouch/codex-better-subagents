#!/usr/bin/env bash
# Install the routing guide and worker definitions into your home directory.
# Existing files that differ are backed up with a timestamped .bak suffix before being replaced.
set -euo pipefail

target_home="${CODEX_BETTER_SUBAGENTS_HOME:-${HOME:?Set HOME or CODEX_BETTER_SUBAGENTS_HOME}}"
stamp="$(date +%Y%m%d-%H%M%S)"
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_file() {
  local from="$1" to="$2" backup
  mkdir -p "$(dirname "$to")"
  if [[ -e "$to" ]] && ! cmp -s "$from" "$to"; then
    backup="$(mktemp "$to.bak.$stamp.XXXXXX")"
    cp "$to" "$backup"
    echo "backed up $to -> $backup"
  fi
  cp "$from" "$to"
  echo "installed $to"
}

install_file "$src/ROUTING.md" "$target_home/.agents/rules/subagent-model-routing.md"
for f in "$src"/agents/claude/*.md; do
  install_file "$f" "$target_home/.claude/agents/$(basename "$f")"
done
for f in "$src"/agents/codex/*.toml; do
  install_file "$f" "$target_home/.codex/agents/$(basename "$f")"
done
install_file "$src/codex/worker.config.toml" "$target_home/.codex/worker.config.toml"
install_file "$src/skills/codex-better-subagents/SKILL.md" "$target_home/.agents/skills/codex-better-subagents/SKILL.md"

echo
echo "Done. Point your AGENTS.md or CLAUDE.md at ~/.agents/rules/subagent-model-routing.md."
