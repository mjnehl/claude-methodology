<!--
  TEMPLATE: Customize this file for your project!

  Replace all [PLACEHOLDERS] with project-specific content.
  Delete sections that don't apply. Add sections as needed.

  For existing projects: MERGE this structure with your existing
  CLAUDE.md content — don't lose project-specific documentation.
-->

# [PROJECT NAME]

[One-line description: what does this project do?]

## Quick Reference

### Commands

```bash
# [Replace with your project's actual commands]
# Examples for different stacks:

# Node/TypeScript
npm run build
npm test

# Python
python3 -m pytest
python3 -m mypy src/

# Go
go build ./...
go test ./...

# Expo/React Native
npx expo start
npm run deploy:android
```

### Slash Commands

| Command | Purpose |
|---------|---------|
| `/verify` | Run full verification (build, test, lint, typecheck) |
| `/code-review` | Get code review of recent changes |
| `/tdd` | Test-driven development workflow |
| `/build-fix` | Fix build errors with agent help |
| `/workstream` | Manage parallel worktree sessions |

<!-- Add project-specific commands like /deploy, /demo, etc. -->

### Agents

| Agent | When to Use |
|-------|-------------|
| `tdd-guide` | New features, bug fixes (use proactively) |
| `code-reviewer` | After writing code |
| `architect` | Design decisions |
| `security-reviewer` | Auth/payment code, API keys |

## Documentation

### Methodology

| Document | Purpose |
|----------|---------|
| [.claude/docs/APPROACH.md](.claude/docs/APPROACH.md) | Core development principles |
| [.claude/docs/TESTING.md](.claude/docs/TESTING.md) | Testing strategy (TDD default) |

<!-- Add relevant pattern docs for your project type:
| [.claude/docs/patterns/CLI_TOOL.md](.claude/docs/patterns/CLI_TOOL.md) | CLI patterns |
| [.claude/docs/patterns/FRONTEND_APP.md](.claude/docs/patterns/FRONTEND_APP.md) | Frontend patterns |
| [.claude/docs/patterns/ADHD_FRIENDLY.md](.claude/docs/patterns/ADHD_FRIENDLY.md) | ADHD-friendly UX |
-->

## Tech Stack

<!-- Replace with your actual stack -->
- **Language:** [e.g., TypeScript, Python 3.10+, Go 1.21]
- **Framework:** [e.g., React Native/Expo, FastAPI, none]
- **Database:** [e.g., PostgreSQL, SQLite, none]
- **Testing:** [e.g., Jest, pytest, go test]

## Project Structure

```
[Replace with your actual structure]

# Example for a Python project:
src/
├── models.py      # Data models
├── engine.py      # Core logic
└── cli.py         # CLI interface

# Example for a TypeScript project:
src/
├── components/    # React components
├── services/      # Business logic
├── store/         # State management
└── types/         # TypeScript types
```

## Architecture

<!-- Describe your project's architecture:
- Key components and their responsibilities
- Data flow
- External dependencies
- Important design decisions
-->

[Describe the main components and how data flows through them]

## Key Patterns

<!-- Document patterns specific to this project:
- Data modeling conventions
- Error handling approach
- State management patterns
- API design patterns
-->

- [Pattern 1: e.g., "All domain objects use dataclasses"]
- [Pattern 2: e.g., "Repository pattern for data access"]
- [Pattern 3: e.g., "Result types for fallible operations"]

## Common Mistakes to Avoid

<!-- Add gotchas as they're discovered -->

- [e.g., "Don't mutate state directly — use immutable updates"]
- [e.g., "Don't forget to handle the offline case"]

## Notes

- Run `/verify` after making changes
- Use `tdd-guide` agent proactively for new features
