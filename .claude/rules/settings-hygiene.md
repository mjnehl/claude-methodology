# Settings Hygiene

## How Claude Code Permissions Work

Claude Code has two permission files:

| File | Purpose | Checked In |
|------|---------|------------|
| `.claude/settings.json` | Broad project-level permissions and hooks | Yes |
| `.claude/settings.local.json` | Auto-accumulated from "Allow" clicks | No |

When a user clicks "Allow" on a command prompt, the **exact command text** is saved to `settings.local.json`. This creates bloat over time — full commit messages, specific file paths, and even shell keywords from multi-line commands all get saved as individual permission entries.

## Permission Pattern Rules

### Use Globs in settings.json (CRITICAL)

Always use glob patterns, never exact matches for commands that take arguments:

```json
// WRONG: Exact match — forces user to approve every variant
"Bash(git add)"
"Bash(git commit)"
"Bash(npm run test)"

// CORRECT: Glob — covers all argument variants
"Bash(git add *)"
"Bash(git commit *)"
"Bash(npm run test*)"
```

Note the difference: `Bash(git add)` only matches the bare command. `Bash(git add *)` matches `git add file.ts`, `git add -A`, etc.

### When Reviewing or Creating settings.json

- Every `Bash(command)` entry that commonly takes arguments should end with `*` or ` *`
- Use `command*` (no space) when the suffix is part of the command: `npm run test*` matches `test:unit`
- Use `command *` (with space) when arguments are separate: `git add *` matches `git add file.ts`
- Group related gh commands: `Bash(gh pr *)` covers create, view, list, merge, close, checks

### Hooks Must Be in settings.json

Hooks are configured under the `hooks` key in `.claude/settings.json`. They are NOT auto-discovered from separate files. The canonical hook definitions live in the methodology at `.claude/hooks/hooks.json` and are merged into project settings by `bin/refresh-methodology`.

## Flagging Bloat

If `settings.local.json` exceeds ~50 entries, it likely contains accumulated garbage. Common symptoms:

- Full commit messages saved as permissions
- Shell keywords (`for`, `do`, `if`, `then`, `else`, `done`) as individual entries
- Multi-line scripts or heredocs as permission strings
- Absolute paths to specific files

When you notice this, suggest consolidating useful patterns into `settings.json` with globs and resetting `settings.local.json`.
