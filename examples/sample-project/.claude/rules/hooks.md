# Hooks System

## Overview

Hooks allow automation of verification and quality checks during development.

## Hook Types

- **PreToolUse**: Before tool execution (validation, parameter modification)
- **PostToolUse**: After tool execution (auto-format, checks)
- **Stop**: When session ends (final verification)

## Recommended Hooks

### PreToolUse Hooks

**Git push review**: Review changes before pushing
```json
{
  "matcher": "Bash",
  "condition": "command contains 'git push'",
  "action": "prompt for review"
}
```

**Doc blocker**: Prevent unnecessary documentation file creation
```json
{
  "matcher": "Write",
  "condition": "file ends with .md and not in docs/",
  "action": "require confirmation"
}
```

### PostToolUse Hooks

**Auto-format**: Format files after editing
```json
{
  "matcher": "Edit",
  "condition": "file ends with .ts or .tsx",
  "action": "run prettier"
}
```

**Type check**: Verify types after TypeScript changes
```json
{
  "matcher": "Edit",
  "condition": "file ends with .ts or .tsx",
  "action": "run tsc --noEmit"
}
```

**Console.log warning**: Warn about debug statements
```json
{
  "matcher": "Edit",
  "condition": "file contains console.log",
  "action": "warn"
}
```

### Stop Hooks

**Final verification**: Run full verification before session ends
```json
{
  "matcher": "Stop",
  "action": "run /verify"
}
```

## Configuration

Hooks are configured in project's `.claude/hooks.json` or globally in `~/.claude/settings.json`.

See `operational/hooks/hooks.json` for example configuration.

## Best Practices

1. **Start minimal** - Add hooks as pain points emerge
2. **Don't over-automate** - Hooks should help, not slow down
3. **Test hooks** - Verify they work before relying on them
4. **Document hooks** - Team should know what's automated

## TodoWrite Integration

Use TodoWrite tool to:
- Track progress on multi-step tasks
- Verify understanding of instructions
- Enable real-time steering
- Show granular implementation steps

Todo list reveals:
- Out of order steps
- Missing items
- Extra unnecessary items
- Wrong granularity
- Misinterpreted requirements
