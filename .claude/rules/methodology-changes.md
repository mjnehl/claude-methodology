# Methodology Change Verification

## Before Propagating Changes

When modifying methodology components that affect how Claude Code operates (settings, hooks, agents, commands, rules), verify the change works before running `refresh-methodology`.

### Verification Checklist

1. **Structural check**: Files are valid (JSON parses, markdown renders, scripts have correct syntax)
2. **Functional check**: The component actually does what it's supposed to in a real project
3. **Integration check**: The component doesn't conflict with existing project configuration

### What Requires Functional Verification

| Component | How to Verify |
|-----------|---------------|
| Hooks configuration | Start a Claude session in a project, trigger the hook, confirm it fires |
| Permission patterns | Confirm the glob matches intended commands (test with `fnmatch` or similar) |
| Agent definitions | Invoke the agent in a project, confirm it loads and responds correctly |
| Settings schema | Check Claude Code documentation for the correct location and format |
| Bootstrap scripts | Run `bin/test-bootstrap` |

### Common Pitfalls

- **Wrong file location**: Claude Code only reads configuration from specific paths. Always verify the documented location before creating new config files.
- **Structural vs functional**: A file can be valid JSON in the right directory and still not work because Claude Code doesn't auto-discover it. Test that the tool actually loads it.
- **Propagation amplifies errors**: `refresh-methodology` updates all projects at once. A broken change affects every project simultaneously.

## After Propagating Changes

After running `refresh-methodology`:

1. Spot-check at least one project to confirm the change landed correctly
2. For settings.json changes: verify the merge preserved existing project-specific config
3. For hooks: start a session and confirm hooks are active (check `/hooks` menu if available)

## Run test-bootstrap

Always run `bin/test-bootstrap` after modifying:
- `templates/project-settings.json`
- `bin/new-project`
- `.claude/hooks/` (utility scripts or hook definitions)
- Any file that `new-project` copies to bootstrapped projects
