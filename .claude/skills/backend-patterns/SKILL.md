---
name: backend-patterns
description: Backend architecture patterns, API design, database optimization, and server-side best practices.
---

# Backend Development Patterns

Backend architecture patterns and best practices for scalable server-side applications.

## Methodology Integration

These patterns complement `.claude/docs/patterns/SERVICE_DEVELOPMENT.md` and `.claude/docs/patterns/DIRECT_SERVICES.md` with implementation details.

## API Design Patterns

### RESTful API Structure

```typescript
GET    /api/resources                 # List resources
GET    /api/resources/:id             # Get single resource
POST   /api/resources                 # Create resource
PUT    /api/resources/:id             # Replace resource
PATCH  /api/resources/:id             # Update resource
DELETE /api/resources/:id             # Delete resource

# Query parameters for filtering, sorting, pagination
GET /api/resources?status=active&sort=created&limit=20&offset=0
```

### Repository Pattern

```typescript
// Abstract data access logic
interface ResourceRepository {
  findAll(filters?: Filters): Promise<Resource[]>
  findById(id: string): Promise<Resource | null>
  create(data: CreateDto): Promise<Resource>
  update(id: string, data: UpdateDto): Promise<Resource>
  delete(id: string): Promise<void>
}

class DatabaseResourceRepository implements ResourceRepository {
  async findAll(filters?: Filters): Promise<Resource[]> {
    let query = db.from('resources').select('*')

    if (filters?.status) {
      query = query.eq('status', filters.status)
    }

    const { data, error } = await query
    if (error) throw new Error(error.message)
    return data
  }
}
```

### Service Layer Pattern

```typescript
// Business logic separated from data access
class ResourceService {
  constructor(private repo: ResourceRepository) {}

  async search(query: string, limit: number = 10): Promise<Resource[]> {
    // Business logic here
    const results = await this.repo.findAll({ query })
    return results.slice(0, limit)
  }
}
```

### Middleware Pattern

```typescript
export function withAuth(handler: Handler): Handler {
  return async (req, res) => {
    const token = req.headers.authorization?.replace('Bearer ', '')

    if (!token) {
      return res.status(401).json({ error: 'Unauthorized' })
    }

    try {
      const user = await verifyToken(token)
      req.user = user
      return handler(req, res)
    } catch (error) {
      return res.status(401).json({ error: 'Invalid token' })
    }
  }
}
```

## Database Patterns

### Query Optimization

```typescript
// GOOD: Select only needed columns
const { data } = await db
  .from('resources')
  .select('id, name, status')
  .eq('status', 'active')
  .order('created_at', { ascending: false })
  .limit(10)

// BAD: Select everything
const { data } = await db.from('resources').select('*')
```

### N+1 Query Prevention

```typescript
// BAD: N+1 query problem
const items = await getItems()
for (const item of items) {
  item.related = await getRelated(item.related_id)  // N queries
}

// GOOD: Batch fetch
const items = await getItems()
const relatedIds = items.map(i => i.related_id)
const related = await getRelatedByIds(relatedIds)  // 1 query
const relatedMap = new Map(related.map(r => [r.id, r]))

items.forEach(item => {
  item.related = relatedMap.get(item.related_id)
})
```

## Caching Strategies

### Cache-Aside Pattern

```typescript
async function getResourceWithCache(id: string): Promise<Resource> {
  const cacheKey = `resource:${id}`

  // Try cache
  const cached = await redis.get(cacheKey)
  if (cached) return JSON.parse(cached)

  // Cache miss - fetch from DB
  const resource = await db.findUnique({ where: { id } })

  if (!resource) throw new Error('Not found')

  // Update cache (5 minute TTL)
  await redis.setex(cacheKey, 300, JSON.stringify(resource))

  return resource
}
```

## Error Handling Patterns

### Centralized Error Handler

```typescript
class ApiError extends Error {
  constructor(
    public statusCode: number,
    public message: string
  ) {
    super(message)
  }
}

export function errorHandler(error: unknown): Response {
  if (error instanceof ApiError) {
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: error.statusCode })
  }

  if (error instanceof z.ZodError) {
    return NextResponse.json({
      success: false,
      error: 'Validation failed',
      details: error.errors
    }, { status: 400 })
  }

  console.error('Unexpected error:', error)
  return NextResponse.json({
    success: false,
    error: 'Internal server error'
  }, { status: 500 })
}
```

### Retry with Exponential Backoff

```typescript
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  let lastError: Error

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error as Error

      if (i < maxRetries - 1) {
        const delay = Math.pow(2, i) * 1000
        await new Promise(resolve => setTimeout(resolve, delay))
      }
    }
  }

  throw lastError!
}
```

## Authentication & Authorization

### JWT Token Validation

```typescript
export function verifyToken(token: string): JWTPayload {
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload
    return payload
  } catch (error) {
    throw new ApiError(401, 'Invalid token')
  }
}

export async function requireAuth(request: Request) {
  const token = request.headers.get('authorization')?.replace('Bearer ', '')

  if (!token) {
    throw new ApiError(401, 'Missing authorization token')
  }

  return verifyToken(token)
}
```

### Role-Based Access Control

```typescript
type Permission = 'read' | 'write' | 'delete' | 'admin'

const rolePermissions: Record<string, Permission[]> = {
  admin: ['read', 'write', 'delete', 'admin'],
  moderator: ['read', 'write', 'delete'],
  user: ['read', 'write']
}

export function hasPermission(user: User, permission: Permission): boolean {
  return rolePermissions[user.role].includes(permission)
}
```

## Rate Limiting

```typescript
class RateLimiter {
  private requests = new Map<string, number[]>()

  async checkLimit(
    identifier: string,
    maxRequests: number,
    windowMs: number
  ): Promise<boolean> {
    const now = Date.now()
    const requests = this.requests.get(identifier) || []
    const recentRequests = requests.filter(time => now - time < windowMs)

    if (recentRequests.length >= maxRequests) {
      return false
    }

    recentRequests.push(now)
    this.requests.set(identifier, recentRequests)
    return true
  }
}
```

## Logging

### Structured Logging

```typescript
class Logger {
  log(level: 'info' | 'warn' | 'error', message: string, context?: object) {
    const entry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      ...context
    }
    console.log(JSON.stringify(entry))
  }

  info(message: string, context?: object) {
    this.log('info', message, context)
  }

  error(message: string, error: Error, context?: object) {
    this.log('error', message, {
      ...context,
      error: error.message,
      stack: error.stack
    })
  }
}
```

**Remember**: Backend patterns enable scalable, maintainable server-side applications. Choose patterns that fit your complexity level.
