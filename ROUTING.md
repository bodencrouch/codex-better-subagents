# Subagents: pick the model, set the reasoning, run CLI workers

This applies to every coding agent you run (Codex, Claude Code, Cursor, Gemini, Copilot, OpenCode, Grok) whenever it hands work to a subagent or worker. Keep it as the single source of truth and point your other instruction files here. The user asked for this routing, so set the model and reasoning on each spawn when the harness allows it, even where the harness would otherwise inherit the parent's model.

## Pick the tier by the job

| Tier | Models | Start at | Send it |
|---|---|---|---|
| Basic | `gpt-6-luna`, `claude-haiku-5-5` | high | finding files, read-and-report, grep or inventory audits, extraction, classification, formatting, renames, summaries, small known edits, running a command and reporting, checking output against a stated criterion |
| Standard | `gpt-6.1-sol`, `claude-sonnet-5-5` | medium | clear features, bounded bug fixes, refactors, docs, normal UI work, tests from a spec, cheap parallel variations, propagating confirmed facts |
| Deep | `claude-opus-5-5` | medium | ambiguous bugs, cross-file or multi-layer debugging, large migrations, architecture, code review where a miss is costly, reverse-engineering hypotheses and parity audits, premium visual UI |
| Frontier | `gpt-6-astra` | medium | operating browsers, desktop apps, Figma or other GUIs; document-heavy, scientific or security work; the hardest calls; a second opinion on Deep work |

- Start at the lowest tier that can do the job. Move up a tier when a worker fails on judgment (a wrong reading of the system, missed hidden state). When it failed for lack of input, give it the input.
- Prefer `gpt-6.1-sol` over `gpt-6-sol` for new work.
- If you run a cross-vendor proxy that pairs Luna with Haiku, Sol with Sonnet, and Astra with Opus, it can answer a request with the partner model, for example when one vendor's accounts are out of quota. Choose the tier; within a pair either model can do the work. The vendor matters in one place, Codex multi-agent v2, covered below.
- List prices per million tokens, in/out: Sol and Sonnet $2/$10, Opus $4/$20, Astra $10/$50. Astra has to earn five times the Sol price.
- Frontend work needs art direction, references, named anti-patterns and a definition of done. Render and inspect the result before raising the tier or effort.

## Set reasoning with your own judgment

The levels in the table are starting points. The spawning agent picks the level for each job and states it when it spawns.

- Raise one level for cross-file tracing, hidden state, conflicting evidence, architecture, careful review, reverse engineering, or a mistake that would be expensive.
- Lower one level for deterministic, mechanical or latency-bound jobs. Keep Luna and Haiku at high unless the job is trivial.
- Use xhigh or max only for novel research, the hardest debugging, security review, or after high has visibly failed. Higher can score worse: it can exhaust the output budget, time out, or wander out of scope.
- Fix the failure type. Right but slow: lower the level. Verbose: ask for shorter output. Shallow: raise the level or the tier. Missing facts: supply them. Scope creep: lower the level and tighten the packet. The same wrong assumption twice: change the prompt, evidence, tool or model.
- Effort labels are not comparable across vendors. When a harness cannot set reasoning, pick the tier to compensate.
- Always set reasoning explicitly. Some Codex configs default to max, and Codex may start native Sol or Astra subagents at xhigh.

## Check harness compatibility

The transport observations, timing samples, model IDs and standalone worker-profile loading below describe the author's tested October 2026 setup, including a cross-vendor proxy and customized harnesses. They are local observations, not universal behavior or controlled performance benchmarks. Inspect your tool schema, model catalog and CLI help before adapting the examples. Explicit user instructions and platform restrictions take precedence.

## Spawn natively first

- Codex `spawn_agent`: pass `agent_type` set to `basic-worker`, `standard-worker`, `deep-worker` or `frontier-worker`, or pass `model` and `reasoning_effort`. Start workers with a fresh context (`fork_context: false`, or `fork_turns: "none"`) and a self-contained packet; a worker that inherits the whole conversation and can't read its own task will do the parent's task instead. Close finished agents with `close_agent` where it exists, because a finished agent keeps its slot until closed.
- Codex on a GPT model uses multi-agent v2, where the spawn tool takes `task_name` and `fork_turns`. v2 hands the child its task as encrypted content, which works only when the same vendor serves the parent's turn and the child. A cross-vendor proxy can serve a model from either vendor, so v2 spawns often break. In tests on 2026-10-19 and 2026-10-20, 6 of 10 failed, including 4 of 8 with GPT-model children. When OpenAI serves the parent, the task is `gAAAA…` ciphertext that a Claude-served child can't read. When Claude serves the parent, the task is plain text, which an OpenAI-served child rejects with `thinking_signature_invalid`. In a v2 session, use CLI workers for any job that matters. If you do spawn natively, spawn only GPT models (`basic-worker`, `standard-worker`, `frontier-worker`, or a `gpt-*` model) and read each reply. Rerun as a CLI worker any child that failed that way or says its task is unreadable or encrypted. Codex on `claude-opus-5-5` uses v1 (the spawn tool takes `fork_context`). v1 passes plain text, and 5 of 5 spawns from it worked: all four roles and `claude-haiku-5-5`.
- Claude Code Agent tool: pass `subagent_type` set to one of the same four names. Their files set full model IDs (`gpt-6-luna`, `gpt-6.1-sol`, `claude-opus-5-5`, `gpt-6-astra`), so they keep their tier when the aliases change. You can pass `effort` to change the level for one call. The per-call `model` takes only the aliases `haiku`, `sonnet`, `opus` and `fable`. Each alias runs the model set by `ANTHROPIC_DEFAULT_<ALIAS>_MODEL` in `~/.claude/settings.json`, and a proxy setup may change those keys, so an alias can run a different model than its name suggests. When the exact model matters, use a worker type, or a CLI worker with a full ID such as `claude-haiku-5-5`. `CLAUDE_CODE_SUBAGENT_MODEL=haiku` only applies to subagents that name no model. A session runs at most 20 subagents at once.
- Any other harness: use its native subagents when they can choose the model. Otherwise use CLI workers.

## Run CLI workers when native slots run out

Use CLI workers when the native tool has no free slots, a spawn fails, a child can't read its task (the Codex v2 case above), the right model is not offered, or you need more parallel workers than the harness allows. Say so in your update. Write each packet to a file and pass it on stdin. A CLI worker reads the packet as plain text, so it works with either vendor.

```bash
run=~/.cache/agent-runs/$(date +%Y%m%d-%H%M%S)-review; mkdir -p "$run"
# Claude worker: a short job takes about 30 s.
( timeout 45m claude -p --model claude-haiku-5-5 --effort high --permission-mode bypassPermissions \
    --no-session-persistence --output-format json < "$run/w1.task.md" > "$run/w1.json" 2> "$run/w1.err"
  echo $? > "$run/w1.exit" ) &
# Codex worker: -p worker loads ~/.codex/worker.config.toml, which turns off plugins, apps, memories,
# hooks and MCP servers. A trivial job took a median of about 24 s with it and about 49 s without (load average near 50).
( timeout 45m codex exec -p worker -m gpt-6-luna -c model_reasoning_effort=high -C "$repo" -s workspace-write \
    --skip-git-repo-check --ephemeral --color never -o "$run/w2.md" - < "$run/w2.task.md" > "$run/w2.log" 2>&1
  echo $? > "$run/w2.exit" ) &
wait
```

- Research-only Claude worker: replace the permission flag with `--permission-mode plan`, which lets it read and search but not edit or run write commands. Give it a full model ID; in plan mode `--model haiku` ran `gpt-6.1-sol` instead of the Haiku slot's model. In the JSON, `.result` is the reply and the keys of `.modelUsage` name the model that ran.
- `-p worker` leaves the worker without MCP tools and plugin skills. If it needs one, add `-c mcp_servers.<name>.enabled=true`, or drop `-p worker`. Always feed it stdin (the packet, or `< /dev/null`); otherwise `codex exec` waits on an open stdin before it starts.
- Codex native spawns that name no model or effort fall back to the `[agents]` defaults in `~/.codex/config.toml`, if you set any (a cheap model such as `gpt-6-luna` at high is a safe default). Still set both on every spawn.
- Codex sandbox: `-s read-only` for research, `-s danger-full-access` when the worker needs network or writes outside the repo. Drop `--ephemeral` to keep the session for `codex exec resume <id>`.
- Keep `wait` in the same shell call. If you must detach, start each worker with `setsid nohup`; otherwise the wrapper can die when the call returns.
- Run at most 4 CLI workers at once by default, and check `free -h` first on memory-constrained machines.
- Give parallel writers separate worktrees (`claude -w <name>`, `codex exec --worktree`) or directories. Serialize anything with shared live state: games, GUIs, daemons, installs, git commits.

## Task packet and results

Give each worker a plain packet: goal, files it may touch, constraints, how to verify, what to return. Add these lines:

- "You are a worker. Do not spawn subagents or CLI workers," unless the job is to orchestrate.
- The usual gates: no push, PR, publish or destructive action, and preserve dirty work.
- An output bound: a short reply, with long material in a file under `$run`. Huge outputs can crash subagents.
- The spawner checks the result itself (the diff, the command output) and records each worker's model and reasoning level.
