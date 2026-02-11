# Security Guidelines

## Methodology Integration

Security is a verification checkpoint per `.claude/docs/CONTRIBUTING.md`.

## Mandatory Security Checks

Before ANY commit:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized HTML output)
- [ ] CSRF protection enabled
- [ ] Authentication/authorization verified
- [ ] Rate limiting on public endpoints
- [ ] Error messages don't leak sensitive data

## Secret Management

```typescript
// NEVER: Hardcoded secrets
const apiKey = "sk-proj-xxxxx"

// ALWAYS: Environment variables
const apiKey = process.env.API_KEY

if (!apiKey) {
  throw new Error('API_KEY not configured')
}
```

See `.claude/docs/ENVIRONMENTS.md` for environment configuration guidance.

## Security Response Protocol

If security issue found:
1. **STOP immediately**
2. Use **security-reviewer** agent
3. Fix CRITICAL issues before continuing
4. Rotate any exposed secrets
5. Review entire codebase for similar issues
6. Document in ADR if significant change

## Input Validation

```typescript
// Validate at system boundaries
import { z } from 'zod'

const userInputSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
})

// Throws if invalid
const validatedInput = userInputSchema.parse(userInput)
```

## Authentication Checklist

- [ ] Passwords properly hashed (bcrypt, argon2)
- [ ] Session management secure
- [ ] Token expiration configured
- [ ] Logout invalidates session
- [ ] Failed login rate limiting
- [ ] Account lockout after attempts

## Authorization Checklist

- [ ] Role-based access control implemented
- [ ] Resource ownership verified
- [ ] Admin functions protected
- [ ] API endpoints have auth checks
- [ ] Sensitive data access logged

## OWASP Top 10 Awareness

Always consider:
1. Injection (SQL, NoSQL, OS, LDAP)
2. Broken Authentication
3. Sensitive Data Exposure
4. XML External Entities (XXE)
5. Broken Access Control
6. Security Misconfiguration
7. Cross-Site Scripting (XSS)
8. Insecure Deserialization
9. Using Components with Known Vulnerabilities
10. Insufficient Logging & Monitoring
