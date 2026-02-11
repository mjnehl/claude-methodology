# Refactor Clean Command

Safely identify and remove dead code with test verification.

## Instructions

1. Run dead code analysis:
   - Find unused exports and files
   - Find unused dependencies
   - Find unused TypeScript exports

2. Categorize findings by severity:
   - SAFE: Test files, unused utilities
   - CAUTION: API routes, components
   - DANGER: Config files, main entry points

3. Propose safe deletions only

4. Before each deletion:
   - Run full test suite
   - Verify tests pass
   - Apply change
   - Re-run tests
   - Rollback if tests fail

5. Show summary of cleaned items

## Analysis Tools

```bash
# Find unused exports (if knip installed)
npx knip

# Find unused dependencies
npx depcheck

# Manual search for unused exports
grep -r "export " src/ | grep -v ".test."
```

## Output Format

```
DEAD CODE ANALYSIS
==================

SAFE TO REMOVE:
- src/utils/deprecated.ts (no imports)
- src/components/OldButton.tsx (no imports)

CAUTION (verify manually):
- src/api/legacy.ts (might be used externally)

REMOVED:
- src/utils/deprecated.ts
- src/components/OldButton.tsx

Tests: PASSING
Lines removed: 245
```

## Safety Rules

- Never delete code without running tests first
- Keep removed code in git history
- Document why code was removed in commit message
