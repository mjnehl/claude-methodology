# Plan Command

Create comprehensive implementation plan before writing any code.

## Methodology Integration

Supports the "small, verifiable steps" principle from `.claude/docs/APPROACH.md`.

## What This Command Does

1. **Restate Requirements** - Clarify what needs to be built
2. **Identify Risks** - Surface potential issues and blockers
3. **Create Step Plan** - Break down implementation into phases
4. **Wait for Confirmation** - MUST receive user approval before proceeding

## When to Use

Use `/plan` when:
- Starting a new feature
- Making significant architectural changes
- Working on complex refactoring
- Multiple files/components will be affected
- Requirements are unclear

## How It Works

The planner will:

1. Analyze the request and restate requirements
2. Break down into phases with specific steps
3. Identify dependencies between components
4. **Identify critical user journeys** that need E2E tests
5. Assess risks and potential blockers
6. Present the plan and WAIT for confirmation

## Output Format

```markdown
# Implementation Plan: [Feature Name]

## Requirements Restatement
- [Clear statement of what will be built]

## Implementation Phases

### Phase 1: [Name]
- Step 1
- Step 2

### Phase 2: [Name]
- Step 1
- Step 2

## Critical User Journeys (E2E)
- [Journey 1: e.g., "User creates task, marks complete, verifies persistence"]
- [Journey 2: ...]
- Stories requiring E2E: [list which stories touch these journeys]

## Dependencies
- [External dependencies]
- [Internal dependencies]

## Risks

### Integration Boundaries
Answer these for every boundary where two systems, platforms, or data formats meet:
- Where do two systems exchange data? What assumptions does each side make?
- What platform-specific APIs does this feature depend on? Do they work the same everywhere?
- What permissions, signing, or configuration does this require beyond code?

### Other Risks
- HIGH: [risk]
- MEDIUM: [risk]
- LOW: [risk]

**WAITING FOR CONFIRMATION**: Proceed with this plan? (yes/no/modify)
```

## Important Notes

**CRITICAL**: The planner will **NOT** write any code until you explicitly confirm with "yes" or "proceed".

If you want changes, respond with:
- "modify: [your changes]"
- "different approach: [alternative]"

## ADR Consideration

If the plan involves significant architectural decisions, consider creating an ADR using `.claude/docs/ADR_TEMPLATE.md`.
