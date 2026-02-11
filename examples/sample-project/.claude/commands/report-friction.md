# Report Friction Command

Log friction encountered with a library for tracking and potential improvement.

## Purpose

When you encounter issues, limitations, or awkwardness with a library (internal or external), document it for future reference.

## Usage

`/report-friction <library-name>`

## Instructions

1. Ask for friction details:
   - What went wrong or was awkward?
   - What workaround did you use?
   - How severe is the issue?

2. Append to project's FRICTION.md:
   ```markdown
   ### [Library Name] - [Date]
   **Type**: Internal | npm | pip | etc.
   **Severity**: Minor | Moderate | Major
   **Description**: What went wrong
   **Workaround**: How you worked around it
   **Potential Fix**: What would make this better
   **Replacement Candidate**: Yes/No
   ```

3. If internal library, optionally update central friction tracking

## Friction Categories

- **Bug**: Something doesn't work as documented
- **Missing Feature**: Needed capability doesn't exist
- **Documentation**: Unclear or missing docs
- **API Design**: Awkward or unintuitive interface
- **Performance**: Slow or resource-intensive

## Severity Levels

- **Minor**: Slight inconvenience, easy workaround
- **Moderate**: Significant workaround required
- **Major**: Blocking issue, consider replacement

## Example

```markdown
### axios - 2024-01-25
**Type**: npm
**Severity**: Moderate
**Category**: Bug
**Description**: Request interceptor doesn't handle async properly when token refresh is needed
**Workaround**: Wrapped axios instance with custom async handler
**Potential Fix**: Switch to fetch with custom wrapper
**Replacement Candidate**: Yes - consider internal http-client library
```

## Why Track Friction?

1. **Pattern Recognition**: See recurring issues across projects
2. **Library Decisions**: Data for choosing libraries
3. **Internal Library Opportunities**: Patterns to extract
4. **Knowledge Sharing**: Help future sessions avoid same issues
