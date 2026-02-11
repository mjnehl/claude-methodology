# CLI Tool Pattern

> **Status: Validated** - Refined through:
> - ADR Manager (`adr-cli`) - file ops, templates, interactive prompts
> - Context Gatherer (`ctx`) - code analysis, heuristics, file watching

This pattern covers building command-line tools with good UX, focusing on the unique challenges CLIs present compared to services or web apps.

## When to Use This Pattern

**Good fit:**
- Developer productivity tools
- System administration utilities
- Build/deployment tooling
- File manipulation tools
- Any tool invoked from terminal or scripts

**Characteristics:**
- User is a developer or technical user
- Output goes to terminal and/or files
- Must work both interactively and in scripts/CI

## Core Principles

### 1. Dual-Mode Design

CLIs must work in two contexts:

| Mode | Context | Requirements |
|------|---------|--------------|
| **Interactive** | Human at terminal | Colors, prompts, progress indicators, helpful errors |
| **Scriptable** | CI, pipes, scripts | Machine-parseable output, exit codes, no prompts |

```
# Interactive - rich output
$ adr new
? Title: Use PostgreSQL for persistence
? Status: accepted
✓ Created docs/decisions/0003-use-postgresql.md

# Scriptable - clean output
$ adr new --title "Use PostgreSQL" --status accepted --json
{"path": "docs/decisions/0003-use-postgresql.md", "number": 3}
```

**Detection:** Check if stdout is a TTY. If not, assume scriptable mode.

### 2. Progressive Disclosure

Show simple usage first, reveal complexity on demand:

```
$ adr --help
Usage: adr <command> [options]

Commands:
  new      Create a new ADR
  list     List existing ADRs
  search   Search ADR content

Run 'adr <command> --help' for detailed options.
```

vs.

```
$ adr new --help
Create a new Architecture Decision Record

Usage: adr new [options] [title]

Options:
  -s, --status <status>   Initial status (default: proposed)
  -t, --template <name>   Template to use (default: standard)
  --supersedes <number>   ADR this supersedes
  --json                  Output as JSON
  ...
```

### 3. Predictable Exit Codes

Scripts depend on exit codes:

| Code | Meaning | Example |
|------|---------|---------|
| 0 | Success | Command completed |
| 1 | General error | Invalid input, operation failed |
| 2 | Usage error | Bad arguments, missing required options |
| 130 | Interrupted | User pressed Ctrl+C |

### 4. Helpful Error Messages

Errors should explain what went wrong AND how to fix it:

```
# Bad
Error: File not found

# Good
Error: ADR directory not found at 'docs/decisions/'

To initialize, run:
  adr init

Or specify a custom path:
  adr --dir path/to/decisions list
```

## Project Structure

Typical CLI tool structure:

```
adr-cli/
├── src/
│   ├── cli.ts              # Entry point, argument parsing
│   ├── commands/           # One file per command
│   │   ├── new.ts
│   │   ├── list.ts
│   │   └── search.ts
│   ├── core/               # Business logic (testable without CLI)
│   │   ├── adr.ts          # ADR operations
│   │   └── templates.ts    # Template handling
│   ├── output/             # Output formatting
│   │   ├── terminal.ts     # Pretty printing, colors
│   │   └── json.ts         # Machine-readable output
│   └── utils/
│       ├── fs.ts           # File system operations
│       └── config.ts       # Configuration loading
├── templates/              # ADR templates
├── test/
│   ├── unit/              # Core logic tests
│   ├── integration/       # Command tests
│   └── e2e/               # Full CLI invocation tests
└── package.json
```

**Key separation:** `core/` contains logic that can be tested without invoking the CLI. `commands/` are thin wrappers that parse args and call core functions.

## Testing Strategy

### Unit Tests (core/)

Test business logic in isolation:

```typescript
describe('ADR numbering', () => {
  it('should find next number from existing ADRs', () => {
    const existing = ['0001-first.md', '0002-second.md'];
    expect(nextAdrNumber(existing)).toBe(3);
  });
});
```

### Integration Tests (commands/)

Test commands with real file system (temp directories):

```typescript
describe('adr new', () => {
  it('should create ADR file with correct content', async () => {
    const dir = await createTempDir();
    await runCommand(['new', 'My Decision'], { cwd: dir });

    const files = await fs.readdir(path.join(dir, 'docs/decisions'));
    expect(files).toContain('0001-my-decision.md');
  });
});
```

### E2E Tests

Test actual CLI binary:

```typescript
describe('CLI', () => {
  it('should exit 0 on success', async () => {
    const result = await exec('adr list');
    expect(result.exitCode).toBe(0);
  });

  it('should exit 2 on bad arguments', async () => {
    const result = await exec('adr --invalid-flag');
    expect(result.exitCode).toBe(2);
  });
});
```

## UX Decisions to Document

When building a CLI, explicitly decide and document:

| Decision | Options | Document In |
|----------|---------|-------------|
| Color usage | Always/never/auto-detect | README, ADR if complex |
| Default output format | Human/JSON/both | README |
| Config file location | XDG, dotfile, project-local | README, ADR |
| Interactive prompts | When to prompt vs. require flags | ADR |
| Destructive operations | Require confirmation? --force flag? | ADR |

## Common Libraries

*(To be filled in based on ADR Manager implementation)*

| Purpose | Options |
|---------|---------|
| Argument parsing | commander, yargs, meow |
| Interactive prompts | inquirer, prompts |
| Terminal output | chalk, ora (spinners), cli-table |
| Testing | jest, ava |

## Anti-Patterns

### 1. Wall of Options

**Problem:** `--help` shows 50 flags nobody can remember.
**Solution:** Progressive disclosure. Subcommands with focused options.

### 2. Silent Failures

**Problem:** Command exits 0 but didn't do what was expected.
**Solution:** Explicit success messages in interactive mode. Non-zero exit on any failure.

### 3. Unparseable Output

**Problem:** Output mixes human text with data, impossible to parse.
**Solution:** Separate modes. `--json` for scripts, pretty output for humans.

### 4. Assuming Interactive

**Problem:** Prompts hang in CI because there's no TTY.
**Solution:** Detect non-interactive and either use defaults or error with "missing required flag".

---

## Notes for Refinement

This pattern will be updated as we build validation projects. Key questions to answer:

**From ADR Manager:**
- [ ] What argument parsing library works best with our methodology?
- [ ] How should config files work (project-local vs. global)?
- [ ] What's the right testing balance (unit vs. integration vs. e2e)?
- [ ] How do we handle cross-platform concerns (Windows paths, etc.)?

**From Context Gatherer:**
- [ ] How to test heuristic/fuzzy logic (relevance scoring)?
- [ ] Long-running processes (watch mode) - how to structure?
- [ ] Output formatting for AI consumption - what works best?
- [ ] Caching strategies for expensive operations (code analysis)?
