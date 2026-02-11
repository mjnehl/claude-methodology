# Common Patterns

## Methodology Integration

Supports pattern reuse principles. See also `docs/patterns/` for domain-specific patterns.

## API Response Format

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: {
    total: number
    page: number
    limit: number
  }
}
```

## Custom Hooks Pattern (React)

```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(handler)
  }, [value, delay])

  return debouncedValue
}
```

## Repository Pattern

```typescript
interface Repository<T> {
  findAll(filters?: Filters): Promise<T[]>
  findById(id: string): Promise<T | null>
  create(data: CreateDto): Promise<T>
  update(id: string, data: UpdateDto): Promise<T>
  delete(id: string): Promise<void>
}
```

## Library Reuse

When implementing new functionality:

1. **Check internal libraries first**
   - See `libraries/INDEX.md` for available libraries
   - Libraries are battle-tested and maintained

2. **Check patterns**
   - See `docs/patterns/` for established approaches
   - Patterns provide proven solutions

3. **Evaluate external libraries**
   - Use parallel agents for assessment
   - Check for security, maintenance, fit
   - Track in FRICTION.md if issues arise

4. **Report friction**
   - Use `/report-friction` command for library issues
   - Helps identify replacement candidates

## Result Type Pattern

For operations that can fail:

```typescript
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E }

function divide(a: number, b: number): Result<number> {
  if (b === 0) {
    return { success: false, error: new Error('Division by zero') }
  }
  return { success: true, data: a / b }
}
```

## Service Layer Pattern

```typescript
class UserService {
  constructor(
    private readonly userRepo: UserRepository,
    private readonly emailService: EmailService
  ) {}

  async createUser(data: CreateUserDto): Promise<User> {
    const user = await this.userRepo.create(data)
    await this.emailService.sendWelcome(user.email)
    return user
  }
}
```
