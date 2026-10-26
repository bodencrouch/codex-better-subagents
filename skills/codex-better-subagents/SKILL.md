---
name: codex-better-subagents
description: Use when selecting a subagent model or reasoning effort, planning delegated work, or encountering unreadable encrypted tasks and failed native worker handoffs.
---

# Route subagents by task

Choose the lowest tier that can handle the job correctly. Set the model and reasoning explicitly instead of inheriting the parent's settings.

## Choose a tier

These model IDs are configurable project presets. Use models available in the current provider's catalog; explicit user instructions take precedence.

| Tier | Model presets | Starting effort | Work |
|---|---|---|---|
| Basic | `gpt-6-luna`, `claude-haiku-5-5` | high | Lookups, inventories, extraction, formatting, small known edits |
| Standard | `gpt-6.1-sol`, `claude-sonnet-5-5` | medium | Bounded features, fixes, refactors, documentation |
| Deep | `claude-opus-5-5` | medium | Ambiguous bugs, architecture, migrations, costly reviews, premium visual implementation |
| Frontier | `gpt-6-astra` | medium | Browser/desktop/GUI operation, scientific or document-heavy investigation, hardest calls |

**Routing boundary:** a worker that navigates a browser or operates a GUI belongs to Frontier, including a straightforward account wizard. Coding a normal frontend belongs to Standard; premium visual implementation belongs to Deep.

Raise effort for hidden state, cross-file tracing or costly errors. Lower it for mechanical work; Basic stays high unless the job is trivial. Reserve xhigh/max for exceptional difficulty or an observed failure at high.

## Prepare the dispatch

Each dispatch contains:

1. A concrete goal and completion boundary.
2. Owned files or read-only scope; preserve other people's edits.
3. Model and explicit effort, or a configured role that sets both.
4. Fresh context and a self-contained packet; use the context field supported by the harness.
5. Constraints, verification and a short return format.

Use native delegation when its model controls and transport are suitable. Use a CLI worker when slots are full, the required model is unavailable natively, or the handoff cannot cross providers. An unreadable `gAAAA` task or `thinking_signature_invalid` calls for a plain CLI packet, not another unchanged native retry.

## Example

Run from the checkout to inspect, using an available model:

```bash
codex exec -m gpt-6-luna -c model_reasoning_effort=high \
  -s read-only --ephemeral - <<'TASK'
You are a worker. Do not spawn workers or make changes.
Goal: list tracked files importing parse_config, with file:line evidence.
Scope: this checkout, read-only. Preserve all existing work.
Verify each match. Return locations and any unresolved ambiguity.
TASK
```

## Check the result

Check the worker's evidence before accepting completion. Escalate judgment failures; supply missing input for information failures. Give concurrent writers separate directories or worktrees and respect runtime limits.

Common mistakes: treating GUI navigation as ordinary coding, inheriting premium defaults, sharing a large parent history, or retrying a broken transport unchanged.

The repository's [routing guide](https://github.com/bodencrouch/codex-better-subagents/blob/main/ROUTING.md) contains harness-specific details and CLI orchestration examples.
