# Methodology Documentation

> **READ-ONLY**: These files are managed centrally in `claude-methodology`.
> Do not edit directly - changes will be overwritten by `refresh-methodology`.
> To change methodology, update the source repo. For project-specific needs, use `CLAUDE.md`.

---

These docs are **read-only** and managed by the [claude-methodology](https://github.com/mjnehl/claude-methodology) repository.

## Why Read-Only?

Keeping methodology docs synchronized across projects ensures:
- Consistent practices everywhere
- Improvements propagate to all projects
- No drift between project copies

## How Updates Work

When methodology improves:

1. Changes are made in the `claude-methodology` repo
2. Run `refresh-methodology` to update all projects
3. Your project gets the latest docs automatically

## What If I Need Different Behavior?

**Don't modify these files.** Instead, use the override pattern:

1. **Project-specific guidance** goes in your project's `CLAUDE.md`
2. **Project-specific decisions** go in `docs/decisions/*.md` (ADRs)
3. **Project-specific docs** go in `docs/` (not `.claude/docs/`)

The methodology provides defaults; your project docs provide specifics.

## Example Override

If the methodology says "use Docker Compose" but your project uses Nix:

```markdown
<!-- In your project's CLAUDE.md -->

## Environment

This project uses Nix instead of Docker Compose. See `flake.nix` for details.
```

Your `CLAUDE.md` is read first and takes precedence.

## Files in This Directory

| File | Purpose |
|------|---------|
| `APPROACH.md` | Core principles for human-AI collaboration |
| `CONTRIBUTING.md` | How sessions coordinate, ADR process |
| `TESTING.md` | Testing strategy and verification |
| `ENVIRONMENTS.md` | Dev/test/prod isolation |
| `CI_CD.md` | CI/CD pipelines, Dependabot, branch protection |
| `BOOTSTRAP.md` | How new projects get started |
| `ADR_TEMPLATE.md` | Format for Architecture Decision Records |
| `LIBRARY.md` | Creating and using internal libraries |
| `METHODOLOGY_HEALTH.md` | Metrics dashboard for methodology effectiveness |
| `patterns/*.md` | Domain-specific patterns |

## Questions?

If something in the methodology doesn't work for your situation, that's valuable feedback. Consider:

1. Is your case an exception? → Document in your `CLAUDE.md`
2. Is the methodology wrong? → Update the methodology repo
3. Is something missing? → Add to the methodology repo

The methodology evolves based on real project needs.
