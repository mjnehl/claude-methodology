# Update Documentation Command

Sync documentation from source-of-truth.

## Methodology Integration

Supports "documentation as memory" principle from `.claude/docs/APPROACH.md`.

## Instructions

1. Read package.json scripts section
   - Generate scripts reference table
   - Include descriptions from comments

2. Read .env.example
   - Extract all environment variables
   - Document purpose and format

3. Update docs/ARCHITECTURE.md if structure changed

4. Identify obsolete documentation:
   - Find docs not modified in 90+ days
   - List for manual review

5. Show diff summary

## Output Format

```
DOCUMENTATION UPDATE
====================

Updated:
- docs/ARCHITECTURE.md (new component added)
- README.md (scripts section)

Potentially Stale:
- docs/old-feature.md (last modified 120 days ago)

Verified Current:
- CLAUDE.md
- docs/decisions/*.md
```

## Key Documents to Keep Current

Per methodology:
- `CLAUDE.md` - Entry point for AI
- `docs/ARCHITECTURE.md` - System design
- `docs/decisions/` - ADRs for significant decisions
- `README.md` - Entry point for humans

## Single Source of Truth

- Scripts: package.json
- Environment: .env.example
- Architecture: docs/ARCHITECTURE.md
- Decisions: docs/decisions/*.md
