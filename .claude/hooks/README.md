# Hooks

Automation hooks that trigger on specific events during Claude Code sessions.

## How Hooks Work

Hooks are configured in each project's `.claude/settings.json` under the `hooks` key. The canonical hook definitions live in `hooks.json` in this directory and are merged into project settings by `bin/refresh-methodology`.

**Important:** `.claude/hooks/hooks.json` is the source definition only. Claude Code reads hooks from `.claude/settings.json`, not from this directory.

## Utility Scripts

| Script | Purpose |
|--------|---------|
| `warn-large-files.js` | Warn once per session when a source file exceeds 500 lines |

Utility scripts are copied to projects by `refresh-methodology` and referenced by hook commands.

## Active Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| Dev server blocker | PreToolUse | Block dev servers outside tmux |
| tmux reminder | PreToolUse | Remind to use tmux for long commands |
| git push review | PreToolUse | Remind to verify before pushing |
| Doc file blocker | PreToolUse | Block random .md file creation |
| PR URL logger | PostToolUse | Log PR URL after creation |
| console.log warning | PostToolUse | Warn about debug statements |
| Large file warning | PostToolUse | Warn when files exceed 500 lines |
| Stop check | Stop | Check for console.log before session ends |
