# Direct Services Pattern

> **Part of the [Service Development](./SERVICE_DEVELOPMENT.md) pattern family.**
> This pattern covers building services *without* code generation—the "Direct" end of the spectrum.

## When to Build Direct

Build services directly when:

| Situation | Why Direct Works |
|-----------|------------------|
| **No generator fits** | The service type has no existing generator |
| **Truly unique logic** | Business requirements are one-of-a-kind |
| **Early exploration** | You don't yet know what the pattern should be |
| **Prototyping** | Speed to first version matters more than consistency |
| **One-off service** | You'll never build another one like it |

**Key principle:** Even when building direct, structure code so patterns can emerge and be extracted later.

## The Extraction Mindset

Direct doesn't mean unstructured. Build with these questions in mind:

1. **Which parts are unique to this service?** (Keep these flexible)
2. **Which parts would be the same in a similar service?** (Keep these isolated)
3. **If I built this again, what would I copy-paste?** (Candidate for extraction)

### Code Structure for Extraction

Organize code to separate unique from generic:

```
service/
├── src/
│   ├── core/                 # UNIQUE - Business logic
│   │   ├── domain/          # Domain models, rules
│   │   ├── handlers/        # Request handlers
│   │   └── workflows/       # Business workflows
│   │
│   ├── infrastructure/      # GENERIC - Could be generated
│   │   ├── database/        # DB connection, query patterns
│   │   ├── http/            # HTTP client, request handling
│   │   ├── validation/      # Input validation
│   │   ├── auth/            # Authentication/authorization
│   │   └── observability/   # Logging, metrics, tracing
│   │
│   └── wiring/              # BOILERPLATE - Definitely could be generated
│       ├── routes.ts        # Route definitions
│       ├── config.ts        # Configuration loading
│       ├── server.ts        # Server setup
│       └── dependencies.ts  # Dependency injection
│
├── test/                    # Mirror src/ structure
└── Dockerfile               # Often boilerplate
```

**The insight:** `core/` is where your service's value lives. `infrastructure/` and `wiring/` are often copy-paste between services—prime extraction candidates.

## Service Types That Often Start Direct

Some service types are naturally unique. They typically start direct and may stay direct:

### BFF / Aggregation Services

**What:** Backend-for-frontend services that aggregate multiple backends.

**Why direct:** The aggregation logic is specific to one frontend's needs.

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Mobile App │────►│  Mobile BFF │────►│  Backend A  │
└─────────────┘     │             │────►│  Backend B  │
                    │  (unique    │────►│  Backend C  │
                    │   logic)    │     └─────────────┘
                    └─────────────┘
```

**Extraction signal:** Multiple BFFs with similar aggregation patterns → consider generating the structure.

### Integration Wrappers

**What:** Services that wrap third-party APIs (Stripe, Twilio, etc.).

**Why direct:** Each integration has unique API quirks and business rules.

**Common structure:**
```
stripe-integration/
├── src/
│   ├── core/
│   │   ├── subscriptions.ts    # Your subscription logic
│   │   └── webhooks.ts         # Webhook handling
│   └── infrastructure/
│       ├── stripe-client.ts    # API client wrapper
│       └── retry.ts            # Retry/backoff logic
```

**Extraction signal:** Multiple integrations with same retry/error/webhook patterns → extract infrastructure.

### Workflow / Orchestration Engines

**What:** Services that coordinate multi-step processes.

**Why direct:** Workflows are business-specific; the orchestration logic is unique.

**Consider:**
- State machine libraries for complex flows
- Event sourcing for audit requirements
- Saga pattern for distributed transactions

**Extraction signal:** Multiple workflows with same state management needs → consider workflow framework.

### Real-Time Services

**What:** WebSocket servers, event streams, live updates.

**Why direct:** Real-time requirements vary significantly (latency, fan-out, ordering).

**Key decisions:**
- Connection management strategy
- Message ordering guarantees
- Scaling approach (sticky sessions, pub/sub, etc.)

**Extraction signal:** Multiple real-time services with same connection patterns → extract framework.

### Analytics / Reporting Services

**What:** Services that aggregate data for dashboards and reports.

**Why direct:** Queries and aggregations are specific to business questions.

**Consider:**
- Pre-aggregation vs. real-time queries
- Caching strategies
- Data freshness requirements

**Extraction signal:** Similar query patterns across reports → consider query builder generator.

## Watching for Emergence

As you build direct, watch for patterns that should become generated:

### Signals to Promote to Generated

| Signal | Action |
|--------|--------|
| Copy-pasting between services | Extract shared code or generate it |
| "Just like X but for Y" requests | Parameterize as generator input |
| Inconsistent implementations of same thing | Standardize via generation |
| New team members asking "how does this work?" | Document as generator template |
| Security updates applied inconsistently | Generate from single source |

### The Promotion Process

When you see a pattern emerging:

1. **Identify the stable core** - What's the same every time?
2. **Identify the variants** - What changes between instances?
3. **Build two more direct** - Confirm the pattern is real
4. **Extract to generator** - See [DSL_GENERATION.md](./DSL_GENERATION.md)

**Warning:** Don't extract too early. Premature abstraction is worse than duplication.

## Clean Boundaries

Keep custom logic separate from potential boilerplate:

### Dependency Direction

```
core/ ◄──── infrastructure/ ◄──── wiring/
  │              │                   │
  │              │                   │
  ▼              ▼                   ▼
Unique        Reusable          Boilerplate
logic         patterns          structure
```

Dependencies flow *toward* core. Core doesn't know about infrastructure details.

### Interface Segregation

Define clear interfaces at boundaries:

```typescript
// core/ports/database.ts - Core defines what it needs
interface UserRepository {
  findById(id: string): Promise<User | null>;
  save(user: User): Promise<void>;
}

// infrastructure/database/user-repository.ts - Infrastructure implements it
class PostgresUserRepository implements UserRepository {
  // Implementation details here
}
```

This lets you:
- Test core without infrastructure
- Swap infrastructure without touching core
- Extract infrastructure patterns independently

### Configuration Externalization

Don't embed environment-specific values:

```typescript
// Bad - embedded configuration
const db = new Database('postgres://localhost:5432/mydb');

// Good - externalized configuration
const db = new Database(config.databaseUrl);
```

Generated services always externalize. Direct services should too.

## Testing Direct Services

Test at appropriate levels:

| Level | What to Test | Tools |
|-------|--------------|-------|
| Unit | Core business logic | Jest, isolated mocks |
| Integration | Infrastructure patterns | Test containers, real DBs |
| E2E | Full service behavior | HTTP client, real dependencies |

**Focus unit tests on core.** That's where the unique value lives.

**Integration tests verify infrastructure.** If these pass, the patterns work.

**E2E tests verify wiring.** Everything connected correctly.

## Anti-Patterns

### 1. Monolithic Core

**Problem:** Everything in one big module with no boundaries.
**Symptom:** Can't test business logic without infrastructure.
**Solution:** Separate core from infrastructure with clear interfaces.

### 2. Infrastructure in Core

**Problem:** Database/HTTP/etc. details leak into business logic.
**Symptom:** Business logic tests need real infrastructure.
**Solution:** Dependency inversion—core defines interfaces, infrastructure implements.

### 3. Ignoring Emergence

**Problem:** Building the third identical service without extracting.
**Symptom:** Copy-paste drift, inconsistent implementations.
**Solution:** Watch for patterns and promote to generated.

### 4. Premature Extraction

**Problem:** Extracting patterns after building once.
**Symptom:** Over-general abstractions that don't fit real cases.
**Solution:** Wait for 2-3 instances before extracting.

## Relationship to Other Patterns

- **[SERVICE_DEVELOPMENT.md](./SERVICE_DEVELOPMENT.md)** - Parent pattern with decision framework
- **[DSL_GENERATION.md](./DSL_GENERATION.md)** - When patterns stabilize, migrate here
