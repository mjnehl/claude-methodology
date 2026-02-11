# Claude Methodology

**A portable system for effective human-AI collaboration on software projects.**

## The Problem

AI coding assistants like Claude are powerful, but they have a fundamental limitation: **every session starts from scratch**. Without a system for preserving context, you end up:

- Re-explaining your project in every conversation
- Making inconsistent decisions across sessions
- Losing track of why things are the way they are
- Getting good work from AI that doesn't fit your project's patterns

## The Solution

This methodology turns your codebase into an AI-readable knowledge base. It provides:

1. **Documentation templates** that preserve context across sessions
2. **Principles** for effective human-AI collaboration
3. **Process guidance** for when to document decisions (ADRs)
4. **Scripts** to bootstrap new projects consistently

The result: AI sessions that understand your project and make decisions consistent with past work.

## Who This Is For

- Developers using Claude Code (or similar AI coding tools)
- Teams wanting consistent AI-assisted development practices
- Anyone frustrated by AI "forgetting" project context between sessions

## Core Concepts

### Documentation as Memory

AI sessions are stateless. The codebase—especially documentation—is how knowledge persists:

| Document | Purpose |
|----------|---------|
| `CLAUDE.md` | Entry point for AI - project context, commands, links |
| `docs/ARCHITECTURE.md` | How the system is designed |
| `docs/decisions/*.md` | Why past decisions were made (ADRs) |

**If you want AI to know something, write it down.**

### Human-AI Partnership

This isn't about automating development—it's about effective collaboration:

- **Human:** Sets direction, provides context, makes judgment calls, verifies work
- **AI:** Explores codebases, proposes approaches, implements solutions, explains trade-offs
- **Codebase:** Source of truth, memory across sessions

### Verification Mindset

Trust AI output, but verify it. Run tests, builds, and lints after every significant change. Catch errors before they compound.

### Small, Verifiable Steps

Break work into chunks that can be verified independently. A feature becomes: migration → model → API → tests → docs. Each step is a natural commit boundary.

## Getting Started

### Option 1: Use the Scripts (Recommended)

```bash
# 1. Clone this repo
git clone https://github.com/mjnehl/claude-methodology ~/claude-methodology

# 2. Add scripts to PATH (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/claude-methodology/bin:$PATH"

# 3. Create your first project
new-project my-app

# 4. Start working
cd ~/projects/my-app && claude
```

The `new-project` script creates a project with:
- Methodology docs in `.claude/docs/`
- A starter `CLAUDE.md` to customize
- `docs/decisions/` for ADRs
- Sensible defaults for `.gitignore` and Claude settings

### Option 2: Adopt the Principles

Already have a project? You don't need the scripts. Just:

1. **Create a `CLAUDE.md`** in your project root with:
   - What the project does
   - How to run common tasks
   - Links to architecture/decisions docs

2. **Read `docs/APPROACH.md`** from this repo for collaboration principles

3. **Apply the practices:**
   - Document significant decisions as ADRs
   - Update docs when things change
   - Verify after each change

## Methodology Documents

These docs can be copied to your projects or just referenced:

| Document | What It Covers |
|----------|----------------|
| `docs/APPROACH.md` | Core principles for human-AI collaboration |
| `docs/CONTRIBUTING.md` | How AI sessions should coordinate, when to write ADRs |
| `docs/TESTING.md` | Testing strategy, verification requirements |
| `docs/ENVIRONMENTS.md` | Dev/test/prod isolation, Docker patterns |
| `docs/CI_CD.md` | CI/CD pipelines, Dependabot, branch protection |
| `docs/BOOTSTRAP.md` | Detailed guide for starting new projects |
| `docs/ADR_TEMPLATE.md` | How to write Architecture Decision Records |
| `docs/LIBRARY.md` | Creating and using internal libraries |
| `docs/METHODOLOGY_HEALTH.md` | Metrics dashboard for methodology effectiveness |
| `docs/patterns/*.md` | Domain-specific approaches (DSL generation, etc.) |

## Operational Components

The methodology includes automation tools in `.claude/`:

### Agents

Specialized agents for common tasks:

| Agent | Purpose |
|-------|---------|
| `architect` | System design, ADR drafting |
| `build-error-resolver` | Fixes build failures |
| `code-reviewer` | Reviews code quality, patterns, issues |
| `e2e-runner` | Playwright E2E testing |
| `product-analyst` | Feature scoping and prioritization |
| `security-reviewer` | Security vulnerability analysis |
| `tdd-guide` | Enforces test-driven development |

### Commands

Slash commands for workflows:

| Command | Purpose |
|---------|---------|
| `/verify` | Run full verification suite |
| `/code-review` | Get code review of changes |
| `/tdd` | Test-driven development workflow |
| `/build-fix` | Fix build errors |
| `/e2e` | Run E2E test suite |
| `/plan` | Plan implementation approach |
| `/test-coverage` | Analyze and improve test coverage |
| `/report-friction` | Log library issues |
| `/audit-methodology` | Review methodology for bloat |
| `/orchestrate` | Multi-agent task orchestration |
| `/publish` | Publish methodology changes |
| `/refactor-clean` | Refactor and clean code |
| `/update-docs` | Update documentation |
| `/workstream` | Manage workstreams |

## Library System

Track and reuse code across projects:

- **`libraries/INDEX.md`** - Catalog of available libraries
- **`libraries/FRICTION.md`** - Issues with libraries (internal and external)
- **`FRICTION.md` (per project)** - Project-specific friction tracking

When a library causes issues, log it with `/report-friction`. Patterns across projects inform library improvements or replacements.

## The Boss Agent (Optional)

This repo also functions as a "methodology advisor" when you run Claude from it:

```bash
cd ~/claude-methodology
claude
```

The Boss Agent helps with:
- **Process questions** - "Should this be an ADR?"
- **Planning** - Break down complex tasks before implementation
- **Reviews** - Critique your ADRs or approaches

It does NOT write implementation code—you provide context, it provides guidance.

**Typical workflow:**
1. Ask Boss Agent for guidance on an approach
2. Switch to your project to implement
3. Return to Boss Agent to review your ADR or plan

## Scripts Reference

### `new-project`

Creates a new project with methodology scaffolding:

```bash
new-project <project-name> [base-directory]

# Examples:
new-project my-app              # Creates ~/projects/my-app
new-project my-app ~/work       # Creates ~/work/my-app
```

### `refresh-methodology`

After updating docs in this repo, propagate changes to all your projects:

```bash
refresh-methodology
```

By default, scans `~/projects/`. To scan additional directories, set `CLAUDE_PROJECT_DIRS`:

```bash
# In your ~/.zshrc or ~/.bashrc
export CLAUDE_PROJECT_DIRS="$HOME/projects:$HOME/work:$HOME/dev"
```

### `backport`

Copy project-specific improvements (new agents, commands, rules) back to the methodology repo:

```bash
backport              # Interactive mode
backport --list       # Show differences without copying
backport --file .claude/commands/deploy.md  # Backport specific file
```

The inverse of `refresh-methodology` — pulls innovations from projects upstream.

### `assess-baseline`

Assess an existing project against methodology standards:

```bash
assess-baseline [project-directory]

# Examples:
assess-baseline                 # Assess current directory
assess-baseline ~/projects/app  # Assess specific project
```

Outputs a compliance report with scores and recommendations.

### `test-bootstrap`

Verify the bootstrap process works correctly:

```bash
test-bootstrap                  # Run tests, cleanup
test-bootstrap --keep-example   # Run tests, update examples/sample-project
```

This runs in CI to ensure the bootstrap process doesn't break.

## Example Project

See `examples/sample-project/` for what a bootstrapped project looks like. This is auto-generated by `test-bootstrap --keep-example` and verified in CI.

## Repository Structure

```
claude-methodology/
├── CLAUDE.md           # Boss Agent instructions
├── README.md           # This file (for humans)
├── bin/
│   ├── new-project     # Create new project with scaffolding
│   ├── refresh-methodology # Update methodology in all projects
│   ├── backport        # Copy project improvements back to methodology
│   ├── assess-baseline # Assess project against methodology
│   └── test-bootstrap  # Verify bootstrap process
├── docs/               # Methodology documents
│   ├── APPROACH.md     # Core AI-driven development principles
│   ├── CONTRIBUTING.md # Agent collaboration guidelines
│   ├── TESTING.md      # Testing strategy
│   ├── ENVIRONMENTS.md # Environment management
│   ├── CI_CD.md        # CI/CD pipelines, Dependabot, branch protection
│   ├── BOOTSTRAP.md    # Starting new projects
│   ├── ADR_TEMPLATE.md # Decision record format
│   ├── LIBRARY.md      # Library development guide
│   ├── METHODOLOGY_HEALTH.md # Metrics dashboard template
│   └── patterns/       # Domain-specific approaches
├── .claude/            # Claude Code components
│   ├── agents/         # Specialized agents (7)
│   ├── commands/       # Slash commands (14)
│   ├── rules/          # Always-follow guidelines (9)
│   ├── skills/         # Workflow definitions
│   └── hooks/          # Hook configurations
├── libraries/          # Internal library tracking
│   ├── INDEX.md        # Library catalog
│   └── FRICTION.md     # Aggregated friction reports
├── templates/          # Starter files for new projects
└── examples/           # Auto-generated sample project
```

## Evolving the Methodology

When you learn something that should apply across projects:

1. Update the relevant doc in this repo
2. Commit the change
3. Run `refresh-methodology` to update existing projects

The docs are the memory—improvements persist for future sessions.

## FAQ

**Q: Do I need to use Claude Code specifically?**
A: The principles apply to any AI coding assistant. The scripts and Boss Agent are Claude-specific, but the documentation approach works anywhere.

**Q: What if I disagree with something in the methodology?**
A: Adapt it. Your project's docs can override methodology docs. If an exception is common, consider updating the methodology itself.

**Q: How much documentation is too much?**
A: Document decisions, not implementations. Code explains *what*; docs explain *why*. If something would surprise a future reader (human or AI), document it.

**Q: Should every change have an ADR?**
A: No. ADRs are for significant decisions—new components, breaking changes, or choices that affect system design. Bug fixes and small features don't need them.

## Acknowledgments

The operational components (agents, commands, rules, skills, hooks) in this methodology are adapted from [everything-claude-code](https://github.com/anthropics/courses/tree/master/prompt_engineering_interactive_tutorial/Anthropic%201P/everything-claude-code) by Kevin Kern, a winner of Anthropic's [Build with Claude](https://www.anthropic.com/build-with-claude-contest) contest.

Key contributions from everything-claude-code:
- Agent-based workflow automation (code-reviewer, tdd-guide, security-reviewer, etc.)
- Verification loop pattern and `/verify` command
- Hook system for automated quality checks
- Skills framework for reusable workflows

This methodology combines that operational automation with a philosophy-driven approach to documentation, ADRs, and human-AI collaboration.
