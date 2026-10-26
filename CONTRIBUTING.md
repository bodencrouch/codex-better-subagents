# Contributing

Thanks for helping improve this guide.

## Good changes

- A routing rule backed by a measurement. Say what you ran, how many times, on which harness and model versions, and what happened.
- A correction when a harness changes its spawn API or a model ID changes.
- Clearer wording. Keep sentences short and concrete.

## Before you open a pull request

1. Keep the four tier names (`basic-worker`, `standard-worker`, `deep-worker`, `frontier-worker`) stable. Other files refer to them.
2. If you change a worker's model or effort, change it in `agents/claude/`, `agents/codex/` and the table in `ROUTING.md`.
3. Run the same checks as CI:

   ```bash
   shellcheck install.sh
   python3 -c 'import tomllib,glob; [tomllib.load(open(f,"rb")) for f in glob.glob("agents/codex/*.toml")+["codex/worker.config.toml"]]'
   ```

4. Don't include personal paths, hostnames, account names or credentials.

## Reporting problems

Open an issue with the harness name and version, the model, the exact spawn call or command, and the error text.
