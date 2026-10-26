# codex-better-subagents

A routing guide and four ready-made worker definitions that make Codex and Claude Code subagents pick the right model and reasoning level for each job, instead of inheriting the parent's expensive settings.

It also documents a failure most people hit and few explain: Codex multi-agent v2 hands the child its task as encrypted content, so a spawn breaks when a different vendor serves the parent and the child. The guide says when that happens and how to route around it with plain CLI workers.

## What's inside

| Path | What it is |
|---|---|
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

The plugin adds the four Claude workers as `codex-better-subagents:basic-worker` and so on. It does not install `ROUTING.md` or the Codex files; use `install.sh` for those.

### Everything, with install.sh

```bash
git clone https://github.com/bodencrouch/codex-better-subagents.git
cd codex-better-subagents
./install.sh
```

This writes:

- `~/.agents/rules/subagent-model-routing.md`
- `~/.claude/agents/{basic,standard,deep,frontier}-worker.md`
- `~/.codex/agents/{basic,standard,deep,frontier}-worker.toml`
- `~/.codex/worker.config.toml`

Then add one line to your global `AGENTS.md` or `CLAUDE.md` so agents read the guide before they delegate:

```markdown
Before you delegate, read `~/.agents/rules/subagent-model-routing.md`.
```

## Use

In Claude Code, pick a worker by type:

```text
Agent(subagent_type: "basic-worker", prompt: "List every file that imports parse_config and report file:line.")
```

In Codex, pass the role and a fresh context:

```text
spawn_agent(agent_type: "standard-worker", fork_context: false, message: "<self-contained task packet>")
```

From a terminal, when native slots run out or a spawn fails:

```bash
claude -p --model claude-haiku-5-5 --effort high --no-session-persistence --output-format json < task.md
codex exec -p worker -m gpt-6-luna -c model_reasoning_effort=high --ephemeral - < task.md
```

See [`ROUTING.md`](ROUTING.md) for the full rules, including parallel CLI workers.

## Adapting it

The model IDs and prices were current in October 2026. If your provider offers different models, edit the tier table in `ROUTING.md` and the `model` lines in `agents/`. Keep the tier names, because the agent files and the guide refer to them.

The `codex/worker.config.toml` profile turns off plugins, apps, memories and hooks. To keep workers fast, add an `enabled = false` block to `~/.codex/worker.config.toml` for each MCP server in your `~/.codex/config.toml`. That keeps the servers on in your normal sessions.

## Contributing

Issues and pull requests are welcome. Measured results help most: which spawns worked or failed, on which harness version, with which models. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[Apache License 2.0](LICENSE).
