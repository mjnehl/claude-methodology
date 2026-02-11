# Agent Collaboration Guidelines

This document describes how Claude agents should collaborate across sessions and projects. This methodology is portable across projects.

## Multi-Session Coordination

### The Challenge

When working on a project:

- Multiple agent sessions may run sequentially
- Each session starts with limited context
- Decisions made in one session should inform future sessions
- Knowledge should accumulate, not reset

### How Agents Share Knowledge

```
┌─────────────────────────────────────────────────────────────┐
│                    Shared Knowledge                          │
├─────────────────────────────────────────────────────────────┤
│  CLAUDE.md          │ Project context, links to docs        │
│  docs/ARCHITECTURE  │ System design, component overview     │
│  docs/decisions/    │ ADRs - why decisions were made        │
│  .claude/docs/      │ Methodology (portable)                │
│  .claude/commands/  │ Reusable skills                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │ Session 1│   │ Session 2│   │ Session 3│
        └──────────┘   └──────────┘   └──────────┘
```

## Principles for Agent Collaboration

### 1. Read Before Acting

Before making changes, agents should:

1. Read `CLAUDE.md` for project context
2. Check `docs/ARCHITECTURE.md` for system design
   - **If it doesn't exist:** Create it using the template in `.claude/docs/BOOTSTRAP.md`
3. Review relevant `docs/decisions/*.md` for past decisions
4. Understand existing patterns in the codebase

**Why:** Prevents redoing work, contradicting decisions, or breaking patterns.

### 2. Document Decisions

When making non-trivial decisions, create an Architecture Decision Record (ADR):

```markdown
# docs/decisions/NNN-descriptive-title.md
```

ADRs answer future agents' questions:

- "Why is it designed this way?"
- "What alternatives were considered?"
- "What trade-offs were accepted?"

See `ADR_TEMPLATE.md` for the format.

### 3. Update Documentation

After significant changes:

- Update `docs/ARCHITECTURE.md` if system design changed
- Update `CLAUDE.md` if project context changed
- Add ADR if a significant decision was made
- Update README.md if user-facing behavior changed

### 4. Document Project Patterns

When you establish infrastructure that defines **how work should be done** (not just what was built), update `CLAUDE.md` immediately. Future agents won't know to follow patterns that exist only in code.

**Trigger question:** "Would a future agent need to follow this pattern to work correctly on this project?"

If yes → Document in `CLAUDE.md`, not just in code or comments.

| Pattern Type | Examples | CLAUDE.md Section |
|--------------|----------|-------------------|
| Testing infrastructure | Test pyramid, required workflow, test helpers | Testing Requirements |
| Development workflow | Build steps, verification process, CI requirements | Commands / Workflow |
| Code patterns | Architecture patterns, interfaces, conventions | Key Patterns |
| Project constraints | Required tools, version requirements, environment setup | Tech Stack / Setup |

**Anti-pattern:** Creating test helpers, establishing a TDD workflow, or building infrastructure without documenting how future agents should use it. The code exists, but future sessions start fresh and won't discover the pattern without documentation.

**Example:** If you create a `tests/helpers/schema-eval.ts` utility for testing generated code, document:
- That it exists
- When to use it
- How it fits into the required workflow

This is different from documenting architecture (ADRs) - this is documenting **process requirements** for the project.

### 5. Leave the Codebase Better

Each session should:

- Not introduce regressions
- Maintain or improve code quality
- Keep tests passing
- Keep documentation accurate

## Proposing Changes

### Small Changes (Implementation)

For bug fixes, small features, or refactors:

1. Understand the existing code
2. Make the change
3. Run verification (`/verify`)
4. Commit with clear message

### Large Changes (Architectural)

For changes that affect system design:

1. **Research** - Understand current state and constraints
2. **Draft ADR** - Document the decision you're proposing
3. **Implement** - Make the change
4. **Verify** - Run full verification
5. **Update docs** - Update architecture documentation

### Methodology Changes

For changes to the approach itself (files in `.claude/docs/`):

1. **Consider scope** - Does this apply to all projects or just this one?
2. **Discuss trade-offs** - Document why the change is valuable
3. **Update methodically** - Change both docs and any affected projects

## Process for Different Change Types

| Change Type     | ADR Required?  | Doc Update?                    | Verification  |
| --------------- | -------------- | ------------------------------ | ------------- |
| Bug fix         | No             | Maybe                          | `/verify`     |
| Small feature   | No             | README if user-facing          | `/verify`     |
| Refactor        | If significant | ARCHITECTURE if design changes | `/verify`     |
| New component   | Yes            | ARCHITECTURE                   | `/verify`     |
| Project pattern | No             | CLAUDE.md                      | `/verify`     |
| Breaking change | Yes            | All affected docs              | `/verify`     |
| Methodology     | Document in PR | Methodology docs               | Manual review |

**What counts as a "project pattern"?** Testing infrastructure, workflows, conventions, or any process that future agents must follow to work correctly on this project.

**What counts as a "new component"?** New modules, new API endpoints, new services, new CLI commands, or any addition that extends the system's capabilities (not just uses existing capabilities).

## Communication Between Sessions

### What to Capture

Information that future sessions need:

- **Decisions made** - ADRs
- **Problems encountered** - Comments in code or ADRs
- **Work in progress** - TODO comments with context
- **Known issues** - GitHub issues or documented limitations

### What NOT to Assume

Future sessions won't know:

- The conversation history from this session
- Why you chose one approach over another (unless documented)
- Context that wasn't written down

### Handoff Checklist

Before ending a session with incomplete work:

1. Commit any work in progress to a branch
2. Document what's done and what remains
3. Note any blockers or decisions needed
4. Update relevant documentation

## Working with Project-Specific vs. Methodology Docs

### Methodology Docs (`.claude/docs/`)

These are **portable and read-only** - they apply across projects and are managed centrally:

- `APPROACH.md` - AI-driven development principles
- `CONTRIBUTING.md` - This document
- `ENVIRONMENTS.md` - Environment management
- `TESTING.md` - Testing strategy
- `BOOTSTRAP.md` - Starting new projects
- `ADR_TEMPLATE.md` - How to write ADRs
- `METHODOLOGY_HEALTH.md` - Methodology health metrics
- `patterns/*.md` - Domain-specific approaches
- `README.md` - Explains the read-only policy

**Do NOT modify these files directly.** They are overwritten by `refresh-methodology`.

**To improve the methodology:**

1. Make changes in the `claude-methodology` repo
2. Run `refresh-methodology` to propagate to all projects

**To override for a specific project:**

Use the override pattern - project docs take precedence over methodology docs:

```markdown
<!-- In your project's CLAUDE.md -->
## Testing

This project uses Vitest instead of Jest. See docs/TESTING.md for details.
```

Your `CLAUDE.md` and `docs/` files can specify project-specific practices that differ from methodology defaults

### Project-Specific Docs (`docs/`)

These are **local** - they describe this project:

- `ARCHITECTURE.md` - This project's design
- `decisions/` - This project's ADRs

**Changes here should:**

- Describe this project specifically
- Reference methodology docs where appropriate
- Stay in sync with the actual code

### Bridge Doc (`CLAUDE.md`)

This **connects** methodology and project:

- Links to both `.claude/docs/` and `docs/`
- Provides project-specific context
- Contains quick reference for common tasks

## Verification Requirements

Before completing any change:

1. **Build passes** - `npm run build`
2. **Tests pass** - `npm run test`
3. **Lint passes** - `npm run lint`
4. **Types check** - `npx tsc --noEmit`
5. **E2E tests pass** (if suite exists) - `npx playwright test`

Use the `/verify` command to run all checks automatically. Use `/verify full` or `/verify pre-pr` to include E2E tests.

## Agent Support

Use agents proactively to maintain quality:

| Agent | When to Use |
|-------|-------------|
| **code-reviewer** | After writing code, before commits |
| **tdd-guide** | When implementing new features or fixing bugs |
| **security-reviewer** | For auth, payment, or sensitive code |
| **architect** | For significant design decisions, ADR drafting |

See `.claude/agents/` for full documentation.

## Code Review Mindset

Even without human review, agents should:

- Review their own changes critically
- Consider edge cases
- Check for security issues
- Ensure changes match the stated intent
- Verify documentation accuracy

## Project Health Checklist

Agents should periodically verify the project has required documentation:

### Required (Create if Missing)

| Document | Purpose | Template |
|----------|---------|----------|
| `CLAUDE.md` | AI entry point, project context | `.claude/docs/BOOTSTRAP.md` |
| `docs/ARCHITECTURE.md` | System design, components | `.claude/docs/BOOTSTRAP.md` |
| `docs/decisions/` | ADR directory | Create empty directory |

### Recommended

| Document | Purpose | When to Add | Template |
|----------|---------|-------------|----------|
| `ROADMAP.md` | Project priorities and planned work | When planning work | `.claude/docs/BOOTSTRAP.md` |
| `FRICTION.md` | Library & methodology friction | When using libraries or encountering process issues | `.claude/docs/BOOTSTRAP.md` |
| `docs/decisions/001-*.md` | First ADR | When first significant decision is made | `.claude/docs/ADR_TEMPLATE.md` |

### Health Check

When starting work on a project, quickly verify:

- [ ] `CLAUDE.md` exists and is current
- [ ] `docs/ARCHITECTURE.md` exists (create if not)
- [ ] `docs/decisions/` directory exists
- [ ] Recent changes reflected in docs

If any are missing, create them before proceeding with other work.

## Conflict Resolution

If documentation conflicts with code:

- **Code is source of truth** for behavior
- **Update documentation** to match
- **Create ADR** if the discrepancy reveals an undocumented decision

If methodology conflicts with project needs:

- **Project-specific docs** can override methodology
- **Document the exception** in project docs
- **Consider updating methodology** if the exception is common
