# Workstream Management

Create, list, or clean up parallel worktrees for running multiple Claude Code processes simultaneously.

**Arguments:** `$ARGUMENTS` — `create <name>`, `list`, or `cleanup <name> [options]`

## Parse Arguments

The first word of `$ARGUMENTS` is the subcommand. The rest are passed to the script.

- `create <name> [--base <branch>] [--prefix feature|fix|refactor] [--no-install]`
- `list`
- `cleanup <name> [--force] [--delete-remote] [--dry-run]`

If no subcommand is given, run `list`.

## Steps

### For `create`:

1. Run the create script:
   ```
   bash scripts/workstream-create.sh <name> [options]
   ```

2. Report the result:
   - On success: show the worktree directory and branch, remind user to `cd` and start `claude`
   - On failure: show the error and suggest fixes

### For `list`:

1. Run the list script:
   ```
   bash scripts/workstream-list.sh
   ```

2. If any workstreams show as "ready to clean up" (merged + clean), suggest running cleanup.

### For `cleanup`:

1. If no `--force` or `--dry-run` flag, first run with `--dry-run` and show the user what will happen.

2. After user confirms (or if `--force`/`--dry-run` was passed), run:
   ```
   bash scripts/workstream-cleanup.sh <name> [options]
   ```

3. Report the result and remaining workstream count.

## Examples

```
/workstream create tags
/workstream create auth-fix --prefix fix
/workstream list
/workstream cleanup tags --delete-remote
/workstream cleanup old-feature --force
```
