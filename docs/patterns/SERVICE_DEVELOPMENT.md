# Service Development Pattern

This pattern governs how we approach building services. The key insight: **generated and direct services aren't opposites—they're points on a spectrum**.

> "Build with extraction in mind. Even when building directly, always ask: Is this a pattern, or will it become one?"

## The Spectrum

Service development exists on a continuum:

```
Generated ◄──────────────────────────────────────────► Direct
    │                      │                              │
    │                      │                              │
Declarative         Hybrid/Partial                 Imperative
Everything from     Generated structure,           Hand-written
  a spec            custom logic                   throughout
```

**Where you land depends on:**
- Pattern maturity (proven patterns → generate, novel → direct)
- Consistency requirements (many similar services → generate)
- Customization needs (unique logic → direct)
- Time investment (generator setup vs. one-off build)

## Checkpoint Questions

Before building any service, answer these questions:

```
┌─────────────────────────────────────────────────────────────┐
│  1. Does an existing generator handle this?                  │
│     YES → Use it. Don't reinvent.                           │
│     NO  → Continue to question 2                            │
├─────────────────────────────────────────────────────────────┤
│  2. Could an existing generator be extended?                 │
│     YES → Extend it. Better to grow a generator than        │
│           maintain a one-off.                               │
│     NO  → Continue to question 3                            │
├─────────────────────────────────────────────────────────────┤
│  3. Am I writing boilerplate I've written before?           │
│     YES → Consider building a generator first, then use it. │
│     NO  → Continue to question 4                            │
├─────────────────────────────────────────────────────────────┤
│  4. Is this truly unique business logic?                     │
│     YES → Build direct, but structure for future extraction │
│     NO  → Reconsider questions 1-3                          │
└─────────────────────────────────────────────────────────────┘
```

## Decision Framework

```
                    ┌──────────────────────┐
                    │  New Service Needed  │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Have we built       │
                    │  similar services?   │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
         Many times       A few times        Never
              │                │                │
              ▼                ▼                ▼
    ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
    │ Generator       │ │ Hybrid          │ │ Direct          │
    │ likely exists   │ │ approach        │ │ implementation  │
    │ or should       │ │ Generate what   │ │ with extraction │
    │                 │ │ you can, write  │ │ mindset         │
    │ See DSL_        │ │ the rest        │ │                 │
    │ GENERATION.md   │ │                 │ │ See DIRECT_     │
    └─────────────────┘ └─────────────────┘ │ SERVICES.md     │
                                            └─────────────────┘
```

## The Extraction Mindset

Whether you're building generated or direct, think ahead:

**Patterns migrate from direct → generated over time.**

A service built today might reveal a pattern that other services need tomorrow. Write code that can be:

1. **Recognized** - Clear boundaries between generic and specific
2. **Extracted** - Minimal coupling to unique context
3. **Standardized** - Consistent structure with similar services

### Signs a Direct Pattern Should Become Generated

Watch for these signals:

| Signal | Example | Action |
|--------|---------|--------|
| Copy-paste between projects | Same validation logic in 3 services | Extract to generator |
| "Just like X but with Y" requests | "Auth like user-service but for admin" | Parameterize and generate |
| Drift between siblings | Services diverge in error handling | Standardize via generation |
| Onboarding friction | "How does this service structure work?" | Document as generator template |
| Inconsistent updates | Security fix applied to some services, not all | Generate from single source |

### Keeping Direct Code Extractable

When building direct, isolate layers:

```
service/
├── core/              # Business logic - unique per service
│   ├── handlers/      # Request handlers with custom logic
│   └── domain/        # Domain models and rules
├── infrastructure/    # Patterns that could be generated
│   ├── db/           # Database access patterns
│   ├── http/         # HTTP client patterns
│   └── validation/   # Input validation patterns
└── wiring/           # Composition - often boilerplate
    ├── routes.ts     # Route definitions
    └── config.ts     # Configuration loading
```

The `core/` is usually unique. The `infrastructure/` and `wiring/` often become generation candidates.

## Sub-Patterns

This pattern has two specialized sub-patterns:

### DSL_GENERATION.md

For when you're building or using code generators:
- When to use declarative approaches
- The spec → IR → generator flow
- Feature implementation order
- Anti-patterns for generated code

[Read DSL Generation Pattern →](./DSL_GENERATION.md)

### DIRECT_SERVICES.md

For when you're building services directly:
- When direct implementation is appropriate
- Service types that often start direct
- Structuring code for future extraction
- Watching for emergence

[Read Direct Services Pattern →](./DIRECT_SERVICES.md)

## When Each Approach Shines

| Approach | Best For | Cost | Benefit |
|----------|----------|------|---------|
| **Generated** | Many similar services, strong consistency needs | Generator setup time | Consistency, speed for N+1 services |
| **Hybrid** | Core structure shared, business logic unique | Moderate complexity | Balance of consistency and flexibility |
| **Direct** | Truly unique services, early exploration | Per-service effort | Maximum flexibility, fast to start |

## Anti-Patterns

### 1. Always Direct

**Problem:** Building every service from scratch when generators exist.
**Symptom:** Inconsistency, repeated boilerplate, slow onboarding.
**Solution:** Check if generation applies before building direct.

### 2. Over-Generation

**Problem:** Trying to generate everything, even unique logic.
**Symptom:** Complex DSL, generators with too many escape hatches.
**Solution:** Accept that some code is truly unique. Use hybrid approach.

### 3. Premature Generation

**Problem:** Building a generator before the pattern is stable.
**Symptom:** Generator constantly changing, more work than manual coding.
**Solution:** Build 2-3 services direct first. Extract patterns only when stable.

### 4. Extraction Neglect

**Problem:** Building direct without considering future extraction.
**Symptom:** Tightly coupled code that can't be standardized later.
**Solution:** Use extraction mindset even for one-off services.
