# Friction Log

Track issues encountered with libraries in this project.

## How to Use

When you encounter issues with a library (internal or external):
1. Add entry below using the template
2. Note your workaround
3. If significant, copy to `libraries/FRICTION.md` in methodology repo

Use `/report-friction <library-name>` for guided entry creation.

---

## Friction Reports

*No friction reported yet*

---

## Template

```markdown
### [library-name] - [YYYY-MM-DD]
**Type**: Internal | npm | pip | cargo | etc
**Severity**: Minor | Moderate | Major
**Category**: Bug | Missing Feature | Documentation | API Design | Performance
**Description**: [What went wrong or was awkward]
**Workaround**: [How you worked around it]
**Potential Fix**: [What would make this better]
**Replacement Candidate**: Yes/No - [if yes, suggest alternative]
```

---

## Severity Levels

- **Minor**: Slight inconvenience, easy workaround
- **Moderate**: Significant workaround required, slowed progress
- **Major**: Blocking issue, consider replacement

## Categories

- **Bug**: Something doesn't work as documented
- **Missing Feature**: Needed capability doesn't exist
- **Documentation**: Unclear or missing docs
- **API Design**: Awkward or unintuitive interface
- **Performance**: Slow or resource-intensive
