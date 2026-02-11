# Coding Style

## Methodology Integration

Supports maintainable code principles from `.claude/docs/APPROACH.md`.

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate:

```javascript
// WRONG: Mutation
function updateUser(user, name) {
  user.name = name  // MUTATION!
  return user
}

// CORRECT: Immutability
function updateUser(user, name) {
  return {
    ...user,
    name
  }
}
```

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large components
- Organize by feature/domain, not by type

## Error Handling

NEVER swallow errors silently. Bare `catch {}` or `catch { return false }` without explanation hides bugs.

Two acceptable catch patterns:

| Pattern | When to use | Example |
|---------|-------------|---------|
| **Log and re-throw/propagate** | Default for most errors | `catch (e) { console.error('Sync failed:', e); throw e }` |
| **Log and continue** | Genuinely non-fatal, but still observable | `catch (e) { console.warn('Watch sync failed:', e) }` |

Silent swallowing requires an explicit comment justifying **why** silence is acceptable:

```typescript
// WRONG: Silent swallow — hides every bug
try {
  await syncTasks()
} catch {
  return false
}

// WRONG: Returning empty on failure — caller can't distinguish "no data" from "broken"
try {
  return await fetchTasks()
} catch (_) {
  return []
}

// CORRECT: Log and propagate
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('Detailed user-friendly message')
}

// CORRECT: Silent swallow with justification
try {
  await prefetchCache()
} catch {
  /* Expected during offline mode — cache miss is non-fatal, next request will fetch fresh */
}
```

**Code review flag:** Any `catch` block that discards the error without a comment explaining why should be flagged.

## Input Validation

ALWAYS validate user input at system boundaries:

```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

const validated = schema.parse(input)
```

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling (no silent swallows without justification comment)
- [ ] No console.log statements (use proper logging)
- [ ] No hardcoded values (use config/env)
- [ ] No mutation (immutable patterns used)
- [ ] Tests written per `.claude/docs/TESTING.md`

## Avoid Over-Engineering

Per methodology principles:
- Don't add features beyond what was asked
- Don't add unnecessary abstractions
- Keep solutions simple and focused
- Three similar lines is better than a premature abstraction
