# Skill validation

The installable skill was validated with fresh-context dispatch-planning workers before publication. The existing routing guide and worker definitions predate this skill.

## Baseline

Five independent `gpt-6-luna` workers received the same scenario without the skill. Claude CLI bare mode disabled automatic instruction discovery, hooks, plugins and keychain reads; no tools were available. Authentication was supplied through the caller's process environment and is not included in this repository.

All five selected the Basic inventory model and Deep billing model, supplied effort, selected fresh contexts, and chose CLI after the native failures. Four selected Standard for the browser task; one selected Frontier. Basic low effort was allowed by the trivial-job exception and was not scored as a failure.

Observed rationale, baseline sample 1:

> A fresh medium-effort CLI worker can handle the guided navigation while respecting the stop-before-submission boundary and avoiding native handoff issues.

The new skill addresses that classification failure with an observable boundary: operating a browser/GUI uses Frontier; ordinary frontend implementation uses Standard. It also summarizes the pre-existing routing policy.

Baseline decisions, the exact scenario and the rubric are in [evals/dispatch-pressure](../evals/dispatch-pressure/). The same five fresh-context runs with the frozen skill selected all three expected tiers, explicit effort, fresh context and CLI fallback (5/5). Separate one-sample guided checks requested Haiku, Sonnet and Opus and also matched the routing rubric (3/3). These cross-model checks are smoke checks, not five-sample controlled comparisons. These are small planning evaluations, not execution, performance, cost or security benchmarks.

## Publication checks

All baseline and guided responses were read manually, including their rationales. No additional guided failure was observed, so the skill wording was not expanded after GREEN. The frozen skill hash and CLI version are recorded with the public, synthetic decision records. Raw CLI metadata, authentication and local paths are excluded.

A staging-target rehearsal first failed because the original installer required HOME and did not support an explicit destination. The installer now supports `CODEX_BETTER_SUBAGENTS_HOME` and installs the skill there. A second rehearsal exposed same-second backup overwriting; unique `mktemp` suffixes now retain both customizations. Reinstallation with unchanged content creates no extra backup. These checks used temporary staging directories and left the user's configuration untouched.

## Reproduce the planning check

Use a CLI version supporting bare mode, configure its API authentication outside this repository, and select a model available to your provider. Bare mode suppresses automatic instructions, plugins and memory so the control cannot discover the routing policy accidentally. The recorded runs also supplied the system prompt: `You are an independent dispatch-planning worker. Use only supplied task context. Return the requested decisions.`

For a control, pass `evals/dispatch-pressure/scenario.txt` alone. For a guided run, prepend the complete `skills/codex-better-subagents/SKILL.md` to the same scenario. Run each in five separate `claude --bare -p --model gpt-6-luna --effort high --no-session-persistence --disable-slash-commands --tools "" --output-format json` processes. Keep raw CLI metadata outside the checkout and publish only sanitized decisions.

The three cross-model smoke checks requested Haiku at high effort, Sonnet at medium and Opus at medium. Provider-side aliases may resolve differently; the records distinguish requested and CLI-reported model IDs.
