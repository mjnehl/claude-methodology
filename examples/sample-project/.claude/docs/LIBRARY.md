# Library Development Guide

This guide covers creating, using, and maintaining internal libraries.

## What is a Library?

A **library** is directly usable code that's been extracted from projects and battle-tested. It differs from a **pattern** (documented approach/idea) in that it can be copied and used immediately.

## When to Create a Library

Extract code into a library when:
- Same solution implemented in 2+ projects
- Code is stable and well-tested
- Would save significant time reusing
- Solution is general enough for multiple contexts

## Library Requirements

### LIBRARY.md Manifest

Every library must have a `LIBRARY.md` file at its root:

```markdown
# Library: [name]

## Status: Ready | In Development | Deprecated

## Purpose
[What problem this solves]

## Usage

### Installation
[How to add to a project]

### Basic Example
[Minimal working code]

## Dependencies
- [runtime dependencies]
- [dev dependencies]

## Tested With
- [Project A] - [brief description]
- [Project B] - [brief description]

## Known Limitations
- [limitation 1]
- [limitation 2]

## Changelog
- [date]: [changes]
```

### Quality Gates

Before marking a library as "Ready":
- [ ] 80%+ test coverage
- [ ] Used successfully in at least 2 projects
- [ ] Documentation complete (LIBRARY.md)
- [ ] No known critical bugs
- [ ] API is stable (no breaking changes expected)

## Library Structure

```
library-name/
├── LIBRARY.md          # Manifest (required)
├── src/                # Source code
├── tests/              # Test suite
├── examples/           # Usage examples
└── package.json        # (if npm package)
```

## Using Libraries

### Discovery

Check `libraries/INDEX.md` for available libraries before:
- Starting a new project
- Implementing common functionality
- Reaching for external packages

### Integration

1. Copy library to project's `lib/` directory, OR
2. Reference via git submodule, OR
3. Import from shared repo (if published)

### Reporting Issues

When a library doesn't work as expected:
1. Document in project's `FRICTION.md`
2. Use `/report-friction` command
3. Consider contributing a fix

## Versioning

Libraries use **main branch** as source of truth:
- No semver versioning
- Updates are applied to main
- Projects reference main branch
- Breaking changes documented in LIBRARY.md changelog

## Library vs Pattern

| Library | Pattern |
|---------|---------|
| Runnable code | Documented approach |
| Copy and use | Reference and adapt |
| Has tests | Has examples |
| LIBRARY.md manifest | docs/patterns/*.md |

## Library Lifecycle

1. **Extraction** - Code identified as reusable
2. **Development** - Extracted, tested, documented
3. **Ready** - Meets quality gates, added to INDEX.md
4. **Maintenance** - Bug fixes, improvements
5. **Deprecated** - Better solution exists, marked in LIBRARY.md

## Contributing

To add a new library:
1. Create directory in `libraries/`
2. Add LIBRARY.md manifest
3. Ensure tests pass
4. Update `libraries/INDEX.md`
5. Document in relevant project ADRs
