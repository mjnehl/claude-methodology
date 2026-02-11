# Architecture Decision Record Template

Use this template for documenting significant architectural decisions. ADRs create a decision log that helps future contributors (human or agent) understand why things are the way they are.

## When to Write an ADR

Write an ADR when:

- Adding a new major component or system
- Choosing between multiple valid approaches
- Making a decision that's hard to reverse
- Changing existing architecture
- Adopting a new technology or pattern

Don't write an ADR for:

- Bug fixes
- Small refactors
- Implementation details that don't affect architecture
- Decisions that are easily reversible

## File Naming Convention

```
docs/decisions/NNN-short-descriptive-title.md
```

Examples:

- `001-ir-based-generation.md`
- `002-fastify-over-express.md`
- `003-prisma-for-database.md`

Numbers should be sequential. Gaps are acceptable (from rejected/superseded ADRs).

## Template

Copy this template when creating a new ADR:

```markdown
# NNN. Title

**Date:** YYYY-MM-DD

**Status:** Proposed | Accepted | Deprecated | Superseded by [NNN]

## Context

What is the issue that we're seeing that is motivating this decision or change?

Describe:

- The problem or opportunity
- Relevant constraints
- Forces at play (technical, business, team)

## Decision

What is the change that we're proposing and/or doing?

State the decision clearly and concisely.

## Consequences

What becomes easier or more difficult to do because of this change?

### Positive

- Benefit 1
- Benefit 2

### Negative

- Trade-off 1
- Trade-off 2

### Neutral

- Things that change but aren't clearly positive or negative

## Alternatives Considered

### Alternative 1: [Name]

- Description
- Why rejected

### Alternative 2: [Name]

- Description
- Why rejected

## References

- Link to relevant methodology docs (e.g., `.claude/docs/APPROACH.md`, `.claude/docs/patterns/*.md`)
- Link to external resources
- Link to related ADRs
```

## Example ADR

```markdown
# 001. IR-Based Code Generation

**Date:** 2024-01-15

**Status:** Accepted

## Context

We need a code generation approach for the Spark Service Generator. The generator
must:

- Support multiple output formats (TypeScript, OpenAPI, tests)
- Allow adding new generators without modifying existing code
- Provide clear validation boundaries

## Decision

We will use an Intermediate Representation (IR) pattern where:

1. The parser converts YAML specs to a normalized IR
2. Semantic validation happens on the IR
3. Generators consume the IR to produce output

## Consequences

### Positive

- Generators are decoupled from input format
- New output formats can be added independently
- Validation is centralized and testable

### Negative

- Additional abstraction layer to maintain
- IR must be designed to support all generators

### Neutral

- Requires clear IR type definitions

## Alternatives Considered

### Alternative 1: Direct YAML-to-Code Generation

- Parse YAML directly in generators
- Rejected because: duplication of parsing logic, validation scattered

### Alternative 2: AST-Based Approach

- Use TypeScript AST manipulation
- Rejected because: more complex, less readable templates

## References

- See `.claude/docs/patterns/DSL_GENERATION.md` for IR philosophy
```

## Status Lifecycle

```
Proposed → Accepted → [Deprecated | Superseded by NNN]
                   ↘
                    → (remains Accepted indefinitely)
```

- **Proposed**: Under discussion, not yet implemented
- **Accepted**: Decision made and implemented
- **Deprecated**: No longer recommended but still in codebase
- **Superseded by [NNN]**: Replaced by a newer decision

## Tips for Good ADRs

1. **Be concise** - Future readers want the essence, not a novel
2. **Explain the "why"** - The code shows "what", ADRs explain "why"
3. **Document alternatives** - Shows the decision wasn't arbitrary
4. **Include consequences** - Helps future decisions account for trade-offs
5. **Date and status** - Essential for understanding timeline
6. **Link to methodology** - Connect project decisions to general principles
