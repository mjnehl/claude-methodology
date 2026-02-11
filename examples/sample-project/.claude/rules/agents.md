# Agent Orchestration

## Methodology Integration

Agents support the "small steps, verify often" principle from `.claude/docs/APPROACH.md`.

## Available Agents

Located in `.claude/operational/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| architect | System design | Architectural decisions, ADR drafting |
| tdd-guide | Test-driven development | New features, bug fixes |
| code-reviewer | Code review | After writing code |
| security-reviewer | Security analysis | Before commits, auth/payment code |
| build-error-resolver | Fix build errors | When build fails |
| e2e-runner | E2E testing | Critical user flows |

## Immediate Agent Usage

Agents to use proactively without user prompting:

1. **Complex feature requests** - Use **architect** agent for planning and ADR
2. **Code just written/modified** - Use **code-reviewer** agent
3. **Bug fix or new feature** - Use **tdd-guide** agent
4. **Security-sensitive changes** - Use **security-reviewer** agent

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch multiple agents simultaneously:
1. Agent 1: Security analysis of auth.ts
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utils.ts

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer

## Integration with Methodology

When using agents:
1. Agents should reference `.claude/docs/` for project context
2. Architect agent should draft ADRs per `docs/ADR_TEMPLATE.md`
3. Code-reviewer should verify tests per `TESTING.md` requirements
4. All agents should support the verification loop workflow
