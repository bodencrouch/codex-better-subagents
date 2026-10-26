# Changelog

All notable changes to this project are listed here. The project follows [Semantic Versioning](https://semver.org/).

## [1.0.1] - 2026-10-26

### Fixed

- `basic-worker.md` frontmatter was invalid YAML.
- `install.sh` no longer overwrites an earlier backup; backups are timestamped.
- README now says to disable worker MCP servers in `worker.config.toml`, not the main config.
- `ROUTING.md`: the CLI worker example parses in bash, and the Codex `[agents]` default is described as optional.
- CI validates agent frontmatter as YAML.

## [1.0.0] - 2026-10-26

### Added

- `ROUTING.md`: four-tier model routing guide for Codex, Claude Code and other agent harnesses.
- Claude Code and Codex worker definitions for each tier.
- Lean `codex exec -p worker` profile.
- `install.sh`.
