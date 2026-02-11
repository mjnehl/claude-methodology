# Audit Methodology Command

Review the methodology for bloat, redundancy, and consolidation opportunities.

## When to Use

Run `/audit-methodology` after incorporating feedback that touched many files. The boss agent should suggest this when a feedback session modifies 5+ files or adds 100+ lines.

## Instructions

Perform each check below and produce a consolidation report.

### 1. File Size Check

For each methodology file, report line count and flag outliers:

| Category | Threshold |
|----------|-----------|
| `.claude/rules/*.md` | Flag if > 120 lines |
| `.claude/agents/*.md` | Flag if > 150 lines |
| `.claude/commands/*.md` | Flag if > 100 lines |
| `docs/*.md` (core docs) | Flag if > 500 lines |

List flagged files with current line counts.

### 2. Redundancy Scan

Look for the same concept restated in multiple files. For each concept that appears in 3+ files:

- List where it appears
- Identify the **canonical home** (the file where it should be explained in full)
- Identify files where it could be replaced with a cross-reference (e.g., "See TESTING.md for details")

**Intentional repetition is OK.** Each agent and rule file needs enough context to stand alone. A one-line summary + cross-reference is fine. A full paragraph restating the same guidance is not.

### 3. Superseded Content

Check for guidance that has been effectively replaced by newer additions:
- Old phrasing that a newer section covers better
- Sections that were expanded elsewhere but the original wasn't trimmed
- TODO-style placeholders or draft markers that were never resolved

### 4. Signal-to-Noise

Flag verbose sections that could be tightened:
- Multi-paragraph explanations where a table or bullet list would suffice
- Examples that repeat the same point already made in prose
- Boilerplate introductions that don't add information

### 5. Cross-Reference Integrity

Check that cross-references between files are accurate:
- "See X.md" references point to files that exist
- Section references match actual section names
- Agent/command references match actual file names

## Output Format

```markdown
# Methodology Audit Report

## Summary
- Total methodology files: [count]
- Total lines: [count]
- Files flagged for length: [count]
- Redundancy clusters found: [count]
- Superseded content found: [count]
- Broken cross-references: [count]

## Recommendation: [PRUNE / MONITOR / CLEAN]
- **PRUNE** — Significant consolidation opportunities. Review and act now.
- **MONITOR** — Minor issues. Note for next audit.
- **CLEAN** — Methodology is in good shape.

## Flagged Files (by size)
| File | Lines | Threshold | Status |
|------|-------|-----------|--------|

## Redundancy Clusters
### [Concept Name]
- Canonical: [file]
- Redundant in: [files]
- Suggested action: [replace with cross-reference / trim to summary]

## Superseded Content
- [file:section] — [what it says vs. what replaced it]

## Signal-to-Noise
- [file:section] — [why it's verbose, suggested tightening]

## Broken Cross-References
- [file:line] — references [target] which [doesn't exist / has wrong section name]
```

## Important

This command produces a **report only**. No files are modified. The user reviews the report and decides which consolidation actions to take.
