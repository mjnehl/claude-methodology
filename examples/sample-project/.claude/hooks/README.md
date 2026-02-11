# Hooks

Automation hooks that trigger on specific events.

## Available Hooks

See `hooks.json` for full configuration.

### Recommended Hooks

| Hook | Trigger | Purpose |
|------|---------|---------|
| Auto-format | PostToolUse (Edit/Write) | Format code after changes |
| Type-check | PostToolUse (Edit/Write) | Check types after changes |
| Console.log warning | PostToolUse | Warn about debug statements |
| Large file warning | PostToolUse (Edit/Write) | Warn when source files exceed 500 lines |

### Optional Hooks

| Hook | Trigger | Purpose |
|------|---------|---------|
| tmux reminder | PreToolUse (Bash) | Remind to use tmux for long commands |
| git push review | PreToolUse (Bash) | Remind to review before pushing |

## Configuration

Hooks are configured in `hooks.json` and can be customized per project.

## Methodology References

- Hooks automate verification from `docs/CONTRIBUTING.md`
