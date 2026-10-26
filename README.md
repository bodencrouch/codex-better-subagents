# codex-better-subagents

A routing policy, an installable skill and four worker definitions for choosing a model and reasoning level for each delegated job.

The guide also records native-handoff failures observed in the author's cross-vendor proxy setup and a CLI fallback. Those observations are harness-specific, not claims about every Codex or Claude Code installation.

## What's inside

| Path | What it is |
|---|---|
| [`skills/codex-better-subagents/SKILL.md`](skills/codex-better-subagents/SKILL.md) | Discoverable routing skill with tier boundaries, explicit settings and a dispatch example |
| [`ROUTING.md`](ROUTING.md) | The guide: four tiers, how to set reasoning, native spawns, CLI workers and task packets |
| [`agents/claude/`](agents/claude) | Claude Code subagents: `basic-worker`, `standard-worker`, `deep-worker`, `frontier-worker` |
| [`agents/codex/`](agents/codex) | The same four workers as Codex agent roles |
| [`codex/worker.config.toml`](codex/worker.config.toml) | A lean Codex profile for headless `codex exec -p worker` runs |
| [`.claude-plugin/`](.claude-plugin) | Claude Code plugin and marketplace manifests |
| [`install.sh`](install.sh) | Copies everything into place and keeps a timestamped backup of any file it replaces |

## Install

### Claude Code plugin

This repo is also a plugin marketplace. In Claude Code:

```
/plugin marketplace add bodencrouch/codex-better-subagents
/plugin install codex-better-subagents@codex-better-subagents
```

On Claude Code 2.1.275 or later, one step works too:

```
/plugin install codex-better-subagents --marketplace bodencrouch/codex-better-subagents
```

The plugin adds the routing skill and four Claude workers as `codex-better-subagents:basic-worker` and so on. It does not install `ROUTING.md` or the Codex files; use `install.sh` for those.

### Everything, with install.sh

```bash
git clone https://github.com/bodencrouch/codex-better-subagents.git
cd codex-better-subagents
./install.sh
```

This writes:

- `~/.agents/rules/subagent-model-routing.md`
- `~/.agents/skills/codex-better-subagents/SKILL.md`
- `~/.claude/agents/{basic,standard,deep,frontier}-worker.md`
- `~/.codex/agents/{basic,standard,deep,frontier}-worker.toml`
- `~/.codex/worker.config.toml`

To stage an installation elsewhere without changing your home configuration:

```bash
stage_root="$(mktemp -d)"
CODEX_BETTER_SUBAGENTS_HOME="$stage_root" ./install.sh
```

The installer backs up changed files with unique timestamped filenames. Review those backups when updating an existing setup.

Then add one line to your global `AGENTS.md` or `CLAUDE.md` so agents read the guide before they delegate:

```markdown
Before you delegate, read `~/.agents/rules/subagent-model-routing.md`.
```

## Use

In Claude Code, pick a worker by type:

```text
Agent(subagent_type: "basic-worker", prompt: "List every file that imports parse_config and report file:line.")
```

In a Codex harness exposing `task_name` and `fork_turns`, pass a configured role and fresh context:

```text
spawn_agent(task_name: "bounded-fix", agent_type: "standard-worker", fork_turns: "none", message: "<self-contained task packet>")
```

Match the call to your tool schema: some harnesses expose `fork_context: false` instead. Installing role files does not guarantee that every harness registers custom roles automatically; check its available role list.

From a terminal, when native slots run out or a spawn fails:

```bash
claude -p --model claude-haiku-5-5 --effort high --no-session-persistence --output-format json < task.md
codex exec -p worker -m gpt-6-luna -c model_reasoning_effort=high --ephemeral - < task.md
```

See [`ROUTING.md`](ROUTING.md) for the full rules, including parallel CLI workers.

## Adapting it

The model IDs and price examples reflect the author's October 2026 configuration and may be proxy aliases. They are not guarantees of provider availability or current pricing. If your provider offers different models, edit the tier table in `ROUTING.md` and the `model` lines in `agents/`. Keep the tier names, because the agent files and the guide refer to them.

The `codex/worker.config.toml` profile turns off plugins, apps, memories and hooks. To keep workers fast, add an `enabled = false` block to `~/.codex/worker.config.toml` for each MCP server in your `~/.codex/config.toml`. That keeps the servers on in your normal sessions.

The standalone `worker.config.toml` loading convention is supported by the author's installed CLI; other Codex versions may use `[profiles.worker]` in the main configuration instead. Check `codex exec --help` before using `-p worker`, and enable only feature flags your version supports.

## Validation

The skill was evaluated before publication with five no-guidance controls and five fresh-context guided runs. Browser-tier selection matched this policy in 1/5 controls and 5/5 guided runs. Three additional guided model smoke checks passed. This measures dispatch-planning compliance with this policy, not model quality, execution success or cost savings. See [the validation record](docs/skill-validation.md).

## Contributing

Issues and pull requests are welcome. Measured results help most: which spawns worked or failed, on which harness version, with which models. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[Apache License 2.0](LICENSE).
