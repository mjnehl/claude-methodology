# Publish Methodology Command

Commit, push, and propagate methodology changes to all projects.

## Usage

`/publish` or `/publish <commit message>`

## When to Use

After making changes to methodology docs or components that should be propagated to projects.

## Instructions

1. **Check for changes:**
   ```bash
   git status
   git diff
   ```

2. **Stage and commit:**
   - If commit message provided, use it
   - Otherwise, generate descriptive message based on changes
   - Always include `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>`

3. **Push to remote:**
   ```bash
   git push
   ```

4. **Refresh all projects:**
   ```bash
   bin/refresh-methodology
   ```

5. **Confirm completion:**
   - Report number of projects updated
   - Note any warnings about overwritten local changes

## Example

```
User: /publish

Agent: [checks git status, stages changes]
Agent: [commits with descriptive message]
Agent: [pushes to origin]
Agent: [runs bin/refresh-methodology]
Agent: Done. Committed, pushed, and updated 8 projects.
```

## Note

This command is specific to the methodology repo. It won't work in project repos.