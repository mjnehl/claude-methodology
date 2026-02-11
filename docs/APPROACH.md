# AI-Driven Development Approach

This document describes principles for effective human-AI collaboration in software development. These principles apply to any project, regardless of technology stack or domain.

## Core Philosophy

### The Collaboration Model

AI-driven development is a partnership, not automation:

```
┌─────────────────────────────────────────────────────────────────┐
│                         Human                                   │
│  - Sets direction and priorities                                │
│  - Provides context and constraints                             │
│  - Makes judgment calls                                         │
│  - Verifies and accepts work                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Context, feedback
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                          AI                                     │
│  - Explores and researches                                      │
│  - Proposes approaches                                          │
│  - Implements solutions                                         │
│  - Explains trade-offs                                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                     Code, documentation
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Codebase                                  │
│  - Source of truth for what exists                              │
│  - Documentation is memory across sessions                      │
│  - Tests verify correctness                                     │
└─────────────────────────────────────────────────────────────────┘
```

Neither human nor AI works alone. The human provides direction and judgment; the AI provides speed and breadth; the codebase provides continuity.

### Documentation as Memory

AI sessions are stateless. Each conversation starts fresh. The codebase—especially documentation—is how knowledge persists:

| What to Document | Where | Why |
|-----------------|-------|-----|
| Project context | `CLAUDE.md` | First thing AI reads |
| System design | `docs/ARCHITECTURE.md` | How components fit together |
| Past decisions | `docs/decisions/*.md` | Why things are the way they are |
| Methodology | `.claude/docs/*.md` | How to work on this project |
| Project roadmap | `docs/ROADMAP.md` | What to build next |

**Principle:** If you want a future AI session to know something, write it down. Verbal explanations are lost when the session ends.

### Document Organization

Separate "how" from "what" in project documentation:

> **CLAUDE.md** is for "How to work in this codebase"
> **docs/ROADMAP.md** is for "What we're building"

This separation keeps CLAUDE.md focused on stable methodology while allowing ROADMAP.md to change frequently as work progresses.

| Content | Location | Rationale |
|---------|----------|-----------|
| CLI commands | CLAUDE.md | Part of "how to work" |
| Agent usage | CLAUDE.md | Part of "how to work" |
| Tech stack | CLAUDE.md | Context for "how to work" |
| Code patterns | CLAUDE.md | Part of "how to work" |
| Common mistakes | CLAUDE.md | Part of "how to work" |
| Project status | docs/ROADMAP.md | Part of "what to build" |
| Definition of done | docs/ROADMAP.md | Part of "what to build" |
| Phase/feature checklists | docs/ROADMAP.md | Part of "what to build" |
| Detailed feature specs | docs/user-stories/ | Overflow for complex features |

**CLAUDE.md should rarely change** once a project is established. Status updates, phase transitions, and progress tracking belong in ROADMAP.md.

### Verification Mindset

Trust AI output, but verify it:

| Layer | Verification |
|-------|-------------|
| Build | Does it compile/transpile? |
| Types | Does it pass type checking? |
| Tests | Do tests pass? |
| Lint | Does it meet style standards? |
| Behavior | Does it actually work? |

**Principle:** Run verification after every significant change. Catch errors immediately, not after they compound.

## Principles

### 1. Context First

AI quality depends on context quality. Before asking AI to work:

**Provide:**
- What you're trying to accomplish (goal)
- Why it matters (motivation)
- Relevant constraints (technical, business, timeline)
- Pointers to relevant code or documentation

**Don't assume AI knows:**
- Your project's conventions
- Recent changes not in documentation
- Business context that isn't written down
- Your preferences (unless documented)

### 2. Small, Verifiable Steps

Break work into chunks that can be verified independently:

**Good:**
```
1. Add database migration for new table
2. Create data model and repository
3. Add API endpoint
4. Write tests
5. Update documentation
```

**Less good:**
```
1. Implement entire feature
```

**Why this matters:**
- Easier to catch errors early
- Easier to course-correct
- Easier to understand what changed
- Natural commit boundaries

### 3. Feature Implementation Pattern

When implementing new features, follow a consistent pattern that enables testing at each layer.

#### Interface First, Then Implementation

Design the contract before writing the code:

1. Define the interface (API, schema, types)
2. Write tests against the interface
3. Implement to pass the tests
4. Integrate with existing code
5. Write/update E2E tests for affected user journeys

**Why this order:**
- Forces clear thinking about requirements
- Tests exist before implementation (TDD)
- Integration issues surface last, when core logic is solid
- E2E validates the complete journey after components are working

**Consider all data flow directions** when designing interfaces. Contracts designed only for the primary creation path break when data flows from other directions:

| Direction | Description | Example |
|-----------|-------------|---------|
| **Create** | User/system creates new data | User fills out a form |
| **Import** | Data arrives from external source | Sync, migration, API ingest |
| **Restore** | Data reconstructed from backup/snapshot | Backup recovery, undo |
| **Clone** | Data duplicated with modifications | Copy task, fork project |

If any of these are foreseeable, accommodate them from the start. A common pattern: `id` is optional-for-create but required-for-import.

#### Breaking Down Features

Large features should be decomposed into independently testable increments:

| Increment Type | Characteristics | Example |
|----------------|-----------------|---------|
| Vertical slice | End-to-end for one case | "User can create a post" |
| Horizontal layer | One layer, multiple cases | "Add validation for all entities" |
| Spike | Exploratory, throwaway | "Can we use library X?" |

**Heuristic:** If you can't write a test for it, it's too big. Break it down further.

**E2E planning:** When breaking down features, identify which user stories touch critical journeys. These stories need E2E tests upon completion — plan for it during decomposition, not after.

#### Layered Systems

Many projects have layers (UI → API → Service → Database). When adding features:

```
┌─────────────────────────────────────────────────────────────┐
│  1. INTERFACE LAYER                                         │
│     Define types, schemas, contracts                        │
│     Tests: Type checking, schema validation                 │
├─────────────────────────────────────────────────────────────┤
│  2. CORE LAYER                                              │
│     Implement business logic                                │
│     Tests: Unit tests with mocks                            │
├─────────────────────────────────────────────────────────────┤
│  3. INTEGRATION LAYER                                       │
│     Wire components together                                │
│     Tests: Integration tests                                │
├─────────────────────────────────────────────────────────────┤
│  4. VERIFICATION                                            │
│     End-to-end user journeys (Playwright)                   │
│     Tests: E2E tests for critical paths from acceptance     │
│     criteria. Failures feed back into the TDD loop.         │
└─────────────────────────────────────────────────────────────┘
```

**Principle:** Changes flow top-down (interface → core → integration). Testing flows bottom-up (unit → integration → E2E). Problems caught at lower layers are cheaper to fix.

#### Pattern-Specific Implementation

Some project types have specific implementation patterns. See `patterns/` for:

- `DSL_GENERATION.md` - Spec → Schema → IR → Generators flow
- *(additional patterns as documented)*

If your project follows a pattern, check for pattern-specific guidance before implementing features.

### 4. Let AI Explore, Then Direct

For unfamiliar territory, let AI research first:

```
Human: "I need to add caching. What are our options?"
AI:    [Explores codebase, proposes options with trade-offs]
Human: "Let's go with option 2. Implement it."
AI:    [Implements with confidence]
```

For familiar territory, be direct:

```
Human: "Add a /health endpoint following the pattern in /api/status"
AI:    [Implements directly]
```

**Principle:** Match your directiveness to your certainty. Uncertain? Let AI explore. Certain? Be specific.

### 5. Explain the Why

AI makes better decisions when it understands intent:

**Less effective:**
> "Add a timeout to the API call"

**More effective:**
> "Add a timeout to the API call. The downstream service sometimes hangs, and we'd rather fail fast than block indefinitely. 5 seconds is probably reasonable but use your judgment."

The "why" helps AI make appropriate trade-offs and catch misalignments.

### 6. Review, Don't Rubber-Stamp

AI-generated code still needs review:

**Check for:**
- Does it actually solve the problem?
- Are there edge cases not handled?
- Does it follow project conventions?
- Is it more complex than necessary?
- Are there security implications?

**Don't assume:**
- Generated code is bug-free
- All edge cases are covered
- It's the simplest solution
- It matches your mental model

### 7. Document Decisions

When AI helps make a decision, capture it:

- **Significant decisions** → ADR (Architecture Decision Record)
- **Implementation notes** → Code comments
- **Project-wide patterns** → Documentation

Future sessions (and future humans) will thank you.

### 8. Observe Before Fixing

When something doesn't work, **add observability first — don't hypothesize and try fixes.**

```
1. Add targeted logging at the suspected boundary
2. Reproduce the problem
3. Read the evidence — let it point to the root cause
4. Remove the diagnostic logging
5. Fix the root cause (using TDD: write the test that should have caught it, then fix)
```

**Why this matters:** A failure can have many possible causes. Without observability, you're guessing. Logging at boundaries narrows the cause systematically.

**Example:** "Watch not receiving data" could be: bridge unavailable, push failing, data format wrong, watch not listening, or signing key mismatch. Only logging at each boundary reveals the actual cause.

**Anti-pattern:** Changing code to "try a fix" without first confirming where the failure is. This wastes time and can introduce new bugs.

## Working with Claude

### What Claude Does Well

- **Exploring codebases** - Finding patterns, understanding structure
- **Implementing defined tasks** - Clear requirements → working code
- **Explaining trade-offs** - Pros/cons of different approaches
- **Writing tests** - Given clear requirements
- **Refactoring** - Improving code while preserving behavior
- **Documentation** - Explaining code, writing READMEs

### What Requires Human Judgment

- **Prioritization** - What to work on next
- **Business logic** - Domain-specific rules
- **User experience** - What feels right
- **Risk assessment** - What could go wrong
- **Scope decisions** - When to stop

### Effective Prompting

**Be specific about scope:**
> "Update the User model to add an email field. Don't change anything else."

**Specify constraints:**
> "This needs to be backward compatible with existing data."

**Indicate completeness:**
> "Give me a complete implementation, not pseudocode."

**Reference existing patterns:**
> "Follow the same pattern as the Product model."

### Context Management

For long tasks, Claude's context window is finite. Help manage it:

- **Point to files** rather than pasting everything
- **Summarize** previous decisions when resuming
- **Use CLAUDE.md** to store persistent context
- **Break large tasks** into focused sessions

## Patterns

Different project types benefit from different approaches. See the `patterns/` directory:

| Pattern | Use For |
|---------|---------|
| `SERVICE_DEVELOPMENT.md` | **Parent pattern** - Decision framework for any service |
| ├─ `DSL_GENERATION.md` | Code generation from declarative specs |
| └─ `DIRECT_SERVICES.md` | Building services without generation |
| `CLI_TOOL.md` | Command-line tools |
| `FRONTEND_APP.md` | Frontend-heavy apps, dashboards, rich UX |
| `LIBRARY_SDK.md` | Reusable libraries, SDKs, extracted packages (draft) |

**The Generation Question:** When building any service, first ask: *Should this be generated?* Check if a generator exists, could be extended, or if you're writing boilerplate you've written before. See `SERVICE_DEVELOPMENT.md` for the full decision framework.

Patterns extend these core principles with domain-specific guidance.

## Claude Code Components

The methodology includes automation that Claude Code automatically discovers in `.claude/`:

| Component | Purpose |
|-----------|---------|
| `.claude/agents/` | Specialized agents (code-reviewer, tdd-guide, security-reviewer, etc.) |
| `.claude/commands/` | Slash commands (/verify, /code-review, /tdd, etc.) |
| `.claude/skills/` | Workflow definitions (verification loop, coding standards) |
| `.claude/rules/` | Always-follow guidelines (coding style, testing, security) |

**Use agents proactively:**
- **code-reviewer** after writing code
- **tdd-guide** for new features
- **security-reviewer** for auth/payment code
- **build-error-resolver** when builds fail

**Key commands:**
- `/verify` - Run full verification suite
- `/code-review` - Get code review
- `/tdd` - Test-driven development workflow
- `/report-friction` - Log library issues

## Relationship to Other Docs

| Document | Purpose |
|----------|---------|
| `BOOTSTRAP.md` | How to start a new project with this methodology |
| `CONTRIBUTING.md` | How AI sessions collaborate, ADR process |
| `ENVIRONMENTS.md` | Dev/test/prod environment management |
| `TESTING.md` | Testing strategy and verification |
| `ADR_TEMPLATE.md` | Format for decision records |
| `LIBRARY.md` | Library development and reuse |
| `patterns/*.md` | Domain-specific approaches |

## Anti-Patterns

### 1. Context Starvation

**Problem:** Asking AI to work without sufficient context.
**Symptom:** AI makes wrong assumptions or asks many clarifying questions.
**Solution:** Provide context upfront. Use CLAUDE.md effectively.

### 2. Verification Skipping

**Problem:** Accepting AI output without running tests/build.
**Symptom:** Errors compound; debugging becomes archaeology.
**Solution:** Verify after every significant change.

### 3. Documentation Neglect

**Problem:** Not updating docs when things change.
**Symptom:** Future sessions make wrong assumptions.
**Solution:** Treat documentation as part of the deliverable.

### 4. Over-Automation

**Problem:** Trying to remove human judgment entirely.
**Symptom:** AI makes decisions that should be human decisions.
**Solution:** Stay in the loop. AI proposes, human decides.

### 5. Under-Delegation

**Problem:** Not letting AI do what it's good at.
**Symptom:** Slow progress; human doing tedious work.
**Solution:** Trust AI with implementation; focus human attention on judgment.
