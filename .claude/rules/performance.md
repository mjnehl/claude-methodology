# Performance Optimization

## Model Selection Strategy

Use the right model for the task:

**Haiku** (Fast, cost-effective):
- Lightweight agents with frequent invocation
- Simple code generation
- Worker agents in multi-agent systems

**Sonnet** (Balanced):
- Main development work
- Orchestrating multi-agent workflows
- Most coding tasks

**Opus** (Deep reasoning):
- Complex architectural decisions
- Maximum reasoning requirements
- Research and analysis tasks

## Context Window Management

Be aware of context limits. Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

## Enhanced Reasoning

For complex tasks requiring deep reasoning:
1. Use Plan Mode for structured approach
2. Break into smaller verification steps
3. Use split role sub-agents for diverse analysis

## Build Troubleshooting

If build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix

## Code Performance

### Database Queries
- Use indexes appropriately
- Avoid N+1 queries
- Paginate large result sets
- Use connection pooling

### Frontend Performance
- Lazy load components
- Memoize expensive computations
- Optimize bundle size
- Use code splitting

### API Performance
- Cache appropriate responses
- Use compression
- Implement pagination
- Consider rate limiting

## Performance Checklist

Before shipping:
- [ ] No obvious N+1 queries
- [ ] Large lists are paginated
- [ ] Expensive computations are cached
- [ ] Bundle size is reasonable
- [ ] No memory leaks in long-running processes
