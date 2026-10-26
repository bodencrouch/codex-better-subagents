# Changelog

All notable changes to this project are listed here. The project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Installable `codex-better-subagents` skill and documented pressure-scenario validation.
- Explicit staging destination through `CODEX_BETTER_SUBAGENTS_HOME`.
- Source provenance and harness compatibility notes.

### Fixed

- Changed-file backups stay unique when installations happen within the same second.
- Codex examples distinguish harness-specific context and profile APIs.

## [1.1.0] - 2026-10-26

### Added

- Claude Code plugin marketplace: `.claude-plugin/marketplace.json` and `plugin.json` ship the four Claude workers.
- CI parses the plugin manifests as JSON.

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
