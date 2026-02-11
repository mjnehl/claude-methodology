# DSL-Driven Code Generation Pattern

> **Part of the [Service Development](./SERVICE_DEVELOPMENT.md) pattern family.**
> This pattern covers *when and how* to build with code generation—the "Generated" end of the spectrum.

This pattern applies to projects that generate code from declarative specifications. Inspired by Boris Cherny's approach to type-safe code generation.

## When to Use This Pattern

**Good fit:**
- Generating multiple similar services from specs (APIs, microservices)
- OpenAPI/GraphQL schema-driven development
- Infrastructure-as-code tools
- Any project where consistency across outputs matters more than flexibility

**Poor fit:**
- One-off applications with unique requirements
- Exploratory prototypes where the shape is unknown
- Projects where hand-tuning is the point (ML models, creative tools)

## Core Philosophy

### The Problem with Traditional Service Development

Traditional service development follows an imperative pattern:

1. Write boilerplate code manually
2. Copy patterns from other services
3. Hope consistency is maintained
4. Discover bugs at runtime

This leads to:

- **Inconsistency** - Each service evolves differently
- **Drift** - Patterns diverge over time
- **Errors** - Manual coding introduces bugs
- **Slow onboarding** - New developers must learn each service's quirks

### The Declarative Alternative

Instead of writing services imperatively, we **declare what we want** and **generate the implementation**:

```
Specification (DSL) → Intermediate Representation → Generated Code
```

This inverts the traditional model:

- **Specification** defines _what_ the service does
- **Generator** decides _how_ to implement it
- **Output** is predictable, consistent, and correct by construction

## Key Principles

### 1. DSL as Single Source of Truth

The DSL specification is the authoritative description of a service. Everything else—code, documentation, tests—is derived from it.

**Why this matters:**

- Changes happen in one place
- Documentation can't drift from implementation
- Tests validate what's specified, not what was manually coded

**Anti-pattern:** Adding features directly to generated code instead of the DSL.

### 2. Intermediate Representation (IR)

The IR is a normalized, typed structure that sits between input and output:

```
          ┌─────────────┐
YAML ────►│   Parser    │────► IR
          └─────────────┘       │
                                ▼
          ┌─────────────┐  ┌─────────────┐
          │  Validator  │◄─┤             │
          └─────────────┘  │     IR      │
                           │             │
          ┌─────────────┐  └──────┬──────┘
          │ TypeScript  │◄────────┤
          │  Generator  │         │
          └─────────────┘         │
          ┌─────────────┐         │
          │  OpenAPI    │◄────────┤
          │  Generator  │         │
          └─────────────┘         │
          ┌─────────────┐         │
          │    Test     │◄────────┘
          │  Generator  │
          └─────────────┘
```

**Benefits of the IR pattern:**

- **Decoupling** - Frontends (YAML, GUI, API) are independent of backends (generators)
- **Validation** - Semantic checks happen once, on the IR
- **Extensibility** - New generators work with existing parsers
- **Testability** - Each stage can be tested in isolation

### 3. Canonical, Predictable Output

Generated services follow **rigid, predictable patterns**. This is a feature, not a limitation.

**Canonical means:**

- Same input always produces same output
- File structure is deterministic
- Naming conventions are consistent
- No "clever" variations

**Why rigidity is valuable:**

- Developers know where to find things
- Debugging is easier (patterns are familiar)
- Tooling can rely on structure
- Code review focuses on specs, not style

### 4. Guaranteed Correctness

The system validates at multiple stages:

| Stage     | Validation Type | What's Checked                           |
| --------- | --------------- | ---------------------------------------- |
| Parser    | Structural      | YAML syntax, required fields, types      |
| Validator | Semantic        | Entity references, relationship validity |
| Generator | Completeness    | All required files produced              |
| Tests     | Behavioral      | Generated code works correctly           |

**Errors are caught early:**

- Invalid YAML fails immediately
- Missing relationships fail before generation
- Type mismatches fail at compile time
- Behavioral issues fail in generated tests

### 5. Production-Ready Output

Generated code is **deploy-ready**, not a scaffold to be modified.

**What "production-ready" includes:**

- Database migrations (Prisma)
- Input validation (Zod schemas)
- Error handling
- Health endpoints
- Docker configuration
- Graceful shutdown

**What it does NOT mean:**

- Hand-edit generated code for production
- Add "finishing touches" before deploy
- Treat output as a starting point

## When to Extend the DSL vs. Manual Coding

### Extend the DSL when:

- Multiple services need the same capability
- The pattern is general enough to standardize
- It can be expressed declaratively
- The generator can produce correct code for all cases

### Use manual coding when:

- The requirement is truly unique to one service
- Business logic is too complex to express declaratively
- The pattern isn't stable enough to standardize
- Quick prototyping is more valuable than consistency

### The Hybrid Approach

Services can have both generated and manual code:

```
generated/           # Never edit - regenerated on spec change
  routes/
  schemas/
  ...
custom/              # Your business logic
  handlers/
  middleware/
  ...
```

The generated code imports and uses custom code, maintaining the separation.

## Feature Implementation Order

When adding features to a DSL-generation project, follow this specific order. Each step should be tested before proceeding to the next.

### The Implementation Flow

```
┌─────────────────────────────────────────────────────────────┐
│  1. DESIGN THE SPEC SYNTAX                                  │
│     What YAML will users write?                             │
│     Document with examples before implementing              │
├─────────────────────────────────────────────────────────────┤
│  2. UPDATE THE SCHEMA                                       │
│     JSON Schema / validation rules                          │
│     Tests: Invalid specs are rejected                       │
├─────────────────────────────────────────────────────────────┤
│  3. UPDATE THE IR                                           │
│     Type definitions for the intermediate representation    │
│     Tests: Types compile, IR is well-formed                 │
├─────────────────────────────────────────────────────────────┤
│  4. UPDATE THE PARSER                                       │
│     Transform spec → IR                                     │
│     Tests: Spec parses to expected IR                       │
├─────────────────────────────────────────────────────────────┤
│  5. UPDATE THE VALIDATOR                                    │
│     Semantic validation on IR                               │
│     Tests: Invalid IR is rejected with clear errors         │
├─────────────────────────────────────────────────────────────┤
│  6. UPDATE GENERATORS                                       │
│     IR → Generated code (may be multiple generators)        │
│     Tests: Generated code has correct structure             │
├─────────────────────────────────────────────────────────────┤
│  7. MIDDLE-LAYER TESTS                                      │
│     Test generated code behavior without full system        │
│     Tests: Generated schemas/logic work correctly           │
├─────────────────────────────────────────────────────────────┤
│  8. BEHAVIORAL TESTS                                        │
│     Test full generated system end-to-end                   │
│     Tests: Generated service behaves correctly              │
└─────────────────────────────────────────────────────────────┘
```

### Why This Order Matters

**Schema before IR:** The schema defines what's valid input. If you change the IR first, you may accept invalid specs.

**Parser before Validator:** The parser creates IR; the validator checks it. Testing in reverse order means validating IR that can't be created.

**Validator before Generators:** Generators assume valid IR. Without validation, generators may produce invalid output or crash.

**Generators before Behavioral Tests:** Behavioral tests run generated code. The code must exist and be structurally correct first.

### Test Checkpoints

At each step, verify before proceeding:

| Step | Checkpoint |
|------|------------|
| Schema | `npm test` - schema tests pass |
| IR | `npm run build` - types compile |
| Parser | `npm test` - parser tests pass |
| Validator | `npm test` - validator tests pass |
| Generators | `npm test` - generator unit tests pass |
| Middle-layer | `npm test` - runtime tests pass |
| Behavioral | `npm run test:behavioral` - E2E tests pass |

### Breaking Down DSL Features

When adding a significant DSL feature, decompose it:

**Example: Adding "soft delete" to entities**

1. **Spec syntax:** `softDelete: true` on entity
2. **Schema:** Add `softDelete` boolean to entity schema
3. **IR:** Add `softDelete: boolean` to `EntityIR` type
4. **Parser:** Populate `softDelete` from spec (default: false)
5. **Validator:** No new validation needed
6. **Prisma generator:** Add `deletedAt DateTime?` field
7. **Zod generator:** Handle `deletedAt` in schemas
8. **Routes generator:** Filter by `deletedAt: null`, use update instead of delete
9. **Middle-layer tests:** Routes check for soft delete logic
10. **Behavioral tests:** Verify soft-deleted records are hidden

Each step is independently testable. If step 6 fails, you know exactly where the problem is.

## Anti-Patterns to Avoid

### 1. Modifying Generated Code

**Problem:** Changes are lost on regeneration.
**Solution:** Extend the DSL or use custom code directories.

### 2. Generator-Specific Logic in the Parser

**Problem:** Couples parsing to a specific output format.
**Solution:** Keep the IR generator-agnostic.

### 3. Overly Flexible DSL

**Problem:** If everything is configurable, nothing is canonical.
**Solution:** Opinionated defaults with limited escape hatches.

### 4. Skipping Validation

**Problem:** Invalid IR causes confusing generator errors.
**Solution:** Semantic validation before generation.

### 5. Non-Deterministic Output

**Problem:** Same input producing different output breaks caching, diffs, tests.
**Solution:** Sort collections, use stable formatting, avoid timestamps.

## Typical Workflow with AI

When working with Claude on a DSL-generation project:

1. **Spec changes first** - Modify the DSL spec, not generated code
2. **Regenerate** - Run the generator after spec changes
3. **Validate** - Check that generated output is correct
4. **Custom code** - Add business logic in custom directories only
5. **Test** - Run generated tests plus any custom tests

**What to tell Claude:**
- "This is a DSL-generation project - never modify files in `generated/`"
- "Changes to [feature] should go in the spec file at [path]"
- "After spec changes, run [generate command]"

## Further Reading

### Boris Cherny's Work

- "Programming TypeScript" - O'Reilly, 2019
- Type-safe code generation principles
- Making invalid states unrepresentable

### Related Concepts

- **Domain-Specific Languages** - Martin Fowler's patterns
- **Code Generation** - Lex/Yacc lineage, modern metaprogramming
- **Infrastructure as Code** - Terraform, Pulumi (declarative approach)
- **API-First Design** - OpenAPI code generation

### Implementation Patterns

- **Visitor Pattern** - For IR traversal
- **Builder Pattern** - For output construction
- **Strategy Pattern** - For swappable generators
