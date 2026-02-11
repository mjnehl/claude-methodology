# Project Bootstrap Guide

This document describes how to start a new project using the AI-driven development methodology.

## Overview

A new project needs:

1. **Version control** - Git repository
2. **Methodology docs** - Copied from this repo
3. **Project context** - CLAUDE.md for the AI
4. **Environment spec** - Docker Compose or equivalent
5. **Verification** - Test and lint configuration

## Quick Start

### Automated Setup (Recommended)

Use the bootstrap script from this repo:

```bash
# Clone methodology repo (if not already)
git clone https://github.com/your-org/claude-methodology.git

# Create new project
./claude-methodology/bin/new-project my-project

# Or specify location
./claude-methodology/bin/new-project my-project ~/work
```

This creates the project structure, copies methodology docs to `.claude/docs/`, initializes git, and makes the initial commit.

To update methodology docs in existing projects later:

```bash
./claude-methodology/bin/refresh-methodology
```

### Manual Setup

If you prefer manual setup or need to understand each step:

### 1. Create Repository

```bash
mkdir my-project
cd my-project
git init
```

### 2. Copy Methodology

Copy the methodology docs to your project:

```bash
# From this repo, copy docs to your project's .claude/docs/
mkdir -p .claude/docs
cp -r /path/to/claude-methodology/docs/* .claude/docs/
```

Or set up as a git subtree for updates:

```bash
git subtree add --prefix=.claude/docs \
  https://github.com/your-org/claude-methodology.git main --squash
```

### 3. Create CLAUDE.md

Create the project entry point for AI sessions:

```markdown
# Project Name

Brief description of what this project does.

## Quick Reference

| Command | Purpose |
|---------|---------|
| `npm run dev` | Start development server |
| `npm test` | Run tests |
| `npm run build` | Build for production |

## Architecture

See `docs/ARCHITECTURE.md` for system design.

## Key Decisions

See `docs/decisions/` for ADRs.

## Methodology

This project follows the AI-driven development methodology in `.claude/docs/`.
```

### 4. Set Up Environment

Create the environment specification. See `ENVIRONMENTS.md` for full patterns.

Minimum files needed:
- `docker-compose.yml` - Service definitions
- `.env.template` - Required variables (committed, no secrets)
- `.env` - Actual values (in `.gitignore`)

```bash
# .env.template (committed)
APP_PORT=
DATABASE_URL=
```

### 5. Initialize Project

```bash
# For Node.js
npm init -y
npm install --save-dev typescript jest eslint prettier

# Create initial files
touch tsconfig.json
touch .eslintrc.js
touch .prettierrc
```

### 6. First Commit

```bash
git add .
git commit -m "Initial project setup with methodology"
```

## Project Structure

> **Note:** The `templates/` directory in the methodology repo contains starter
> versions of `CLAUDE.md` and `.claude/settings.json` that `bin/new-project` uses.
> Customize these templates to match your organization's defaults.

### Minimal Structure

```
my-project/
├── .claude/
│   └── docs/              # Methodology (copied from this repo)
│       ├── APPROACH.md
│       ├── CONTRIBUTING.md
│       ├── ENVIRONMENTS.md
│       ├── TESTING.md
│       ├── ADR_TEMPLATE.md
│       └── patterns/
├── docs/
│   ├── ARCHITECTURE.md    # Project-specific architecture
│   ├── ROADMAP.md         # What to build (status, phases, DoD)
│   └── decisions/         # Project-specific ADRs
├── src/                   # Source code
├── tests/                 # Test files (if not co-located)
├── docker-compose.yml     # Environment spec
├── .env.template          # Environment variables template
├── CLAUDE.md              # AI entry point (how to work here)
├── README.md              # Human entry point
└── package.json           # Dependencies
```

### Full Structure (Larger Projects)

```
my-project/
├── .claude/
│   ├── docs/              # Methodology
│   └── commands/          # Custom Claude skills
├── .devcontainer/         # Codespaces config (optional)
├── .github/
│   └── workflows/         # CI/CD
├── docs/
│   ├── ARCHITECTURE.md
│   ├── ROADMAP.md         # What to build
│   ├── SECRETS.md         # Secret sources documentation
│   ├── decisions/
│   └── user-stories/      # Detailed specs (when needed)
├── docker/
│   └── Dockerfile
├── helm/                  # Kubernetes deployment (optional)
├── scripts/
│   ├── env-up.sh
│   ├── env-down.sh
│   └── find-port.sh
├── src/
├── tests/
│   ├── integration/
│   └── e2e/
├── docker-compose.yml
├── .env.template
├── CLAUDE.md
├── README.md
└── package.json
```

## CLAUDE.md Template

The `bin/new-project` script uses `templates/project-claude.md` as a starter. Customize it for your project.

**Key sections to include:**

| Section | Purpose |
|---------|---------|
| Project description | What this project does |
| Quick reference | Common commands |
| Architecture overview | Key components, link to ARCHITECTURE.md |
| Working on this project | Before/after change checklists |
| Methodology links | Point to `.claude/docs/` |

See `templates/project-claude.md` in this repo for the full template.

## ARCHITECTURE.md Template

```markdown
# Architecture

## Overview

[High-level description of the system]

```
[ASCII diagram of major components]
```

## Components

### [Component Name]

**Purpose:** [what it does]

**Location:** `src/[path]/`

**Key files:**
- `[file]` - [purpose]

**Dependencies:** [what it depends on]

**Dependents:** [what depends on it]

### [Next Component]

...

## Data Flow

[How data moves through the system]

## Key Patterns

### [Pattern Name]

[Description and rationale]

**Example:**
```typescript
// Code example
```

## External Dependencies

| Dependency | Purpose | Notes |
|------------|---------|-------|
| [name] | [why we use it] | [version constraints, etc.] |

## Deployment

[How the system is deployed - link to ENVIRONMENTS.md for details]
```

## FRICTION.md Template

Track friction encountered with libraries and methodology. This feedback helps improve both.

```markdown
# Friction Log

Track issues, limitations, and awkwardness encountered in this project.

## Purpose

- Surface problems for resolution
- Inform library and methodology improvements
- Help future sessions avoid known issues

---

## Library Friction

Issues with internal or external libraries used by this project.

<!-- Template:
### [library-name] - [date]
**Type**: Internal | npm | pip | etc.
**Severity**: Minor | Moderate | Major
**Category**: Bug | Missing Feature | Documentation | API Design | Performance
**Description**: What went wrong
**Workaround**: How you worked around it
**Potential Fix**: What would make this better
**Replacement Candidate**: Yes/No - [suggested alternative if yes]
-->

---

## Methodology Friction

Issues with the development process, agents, commands, or methodology docs.

<!-- Template:
### [topic] - [date]
**Area**: Agents | Commands | Docs | Process | Other
**Severity**: Minor | Moderate | Major
**Description**: What was awkward or didn't work
**Context**: What you were trying to do
**Suggestion**: How it could be improved
-->

---

## Resolved

Move resolved items here for historical reference.

<!--
### [item] - [date resolved]
**Resolution**: How it was fixed
-->
```

**When to create:** When the project uses libraries (internal or external) or encounters methodology friction.

**How friction flows:**
- Library friction → Report to library maintainer or `libraries/FRICTION.md` in methodology repo
- Methodology friction → Propose to Methodology Boss for consideration

## ROADMAP.md Template

Track "what we're building" for this project. CLAUDE.md is for "how to work"; ROADMAP.md is for "what to build."

```markdown
# [Project Name] Roadmap

## Current Status

**Phase:** [Phase name, e.g., "MVP", "Beta", "v2.0"]
**Focus:** [Current focus area]

## Definition of Done

What "done" means for the current phase:

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] ...

## Now

Active or about to start.

- **[Category]** Item description

## Next

After current work completes.

- **[Category]** Item description

## Later

On the radar but not prioritized.

- **[Category]** Item description

## Ideas

Not committed, might never happen.

- Item description

## User Stories

For complex features that need detailed specs. Most items don't need this.

| Story | Status | Description |
|-------|--------|-------------|
| [US-001](user-stories/US-001-xxx.md) | Done | Brief description |

## Completed

Recently finished work.

| Date | Item |
|------|------|
| YYYY-MM-DD | Description |
```

**Categories** (for rollup to overall roadmap):
- **Feature** - New capability
- **Quality** - Testing, refactoring, tech debt
- **Infra** - Build, deploy, tooling
- **Docs** - Documentation improvements

**When to update:** When work completes, priorities change, or new work is identified.

### When to Write User Stories

User stories are optional overflow for complex features. Most roadmap items don't need them.

**Write a user story when:**
- Feature has 5+ acceptance criteria
- Significant edge cases need documenting
- UI specification is needed
- Design needs thinking through before coding

**Skip user story when:**
- Simple checklist item
- Requirements obvious from one-liner
- Doing a spike/exploration

### Migration for Existing Projects

If your project has status/roadmap content in CLAUDE.md:

1. Create `docs/ROADMAP.md` from this template
2. Move "Project Status" section from CLAUDE.md to ROADMAP.md
3. Move "Definition of Done" section from CLAUDE.md to ROADMAP.md
4. Add link in CLAUDE.md: `**Roadmap:** See [docs/ROADMAP.md](docs/ROADMAP.md)`
5. Update any documentation tables to include ROADMAP.md

## First ADR

Every project should have at least one ADR documenting the initial technology choices. See `ADR_TEMPLATE.md` for the full format.

Create `docs/decisions/001-initial-tech-stack.md` covering:
- Programming language and runtime
- Web framework (if applicable)
- Database (if applicable)
- Testing framework

This documents *why* these choices were made, helping future contributors understand the foundation.

## Verification Setup

### Package.json Scripts

Minimum scripts for verification:

```json
{
  "scripts": {
    "build": "tsc",
    "test": "jest",
    "lint": "eslint src/",
    "verify": "npm run build && npm test && npm run lint"
  }
}
```

### GitHub Actions

Create `.github/workflows/ci.yml` for CI. See `CI_CD.md` for the complete workflow template, Dependabot configuration, and branch protection setup.

## Checklist

Before starting real work, verify:

- [ ] Git repository initialized
- [ ] Methodology docs in `.claude/docs/`
- [ ] CLAUDE.md created with project context
- [ ] README.md created for humans
- [ ] docker-compose.yml (or equivalent) created
- [ ] .env.template with documented variables
- [ ] .gitignore configured (node_modules, .env, etc.)
- [ ] Test framework installed and configured
- [ ] Linter installed and configured
- [ ] CI workflow created
- [ ] First ADR documenting tech stack
- [ ] Initial commit pushed

## Starting Work with Claude

Once bootstrapped, your first Claude session might be:

> "I just set up this project. Here's the CLAUDE.md: [paste]. I want to implement [first feature]. Let's plan the approach."

Claude will:
1. Read your project context
2. Suggest a breakdown of the work
3. Recommend if an ADR is needed
4. Help implement step by step

## Relationship to Other Docs

| Document | Connection |
|----------|------------|
| `APPROACH.md` | Bootstrap creates the structure; APPROACH guides the work |
| `CONTRIBUTING.md` | First ADR follows this process |
| `ENVIRONMENTS.md` | docker-compose.yml setup follows these principles |
| `TESTING.md` | Test framework setup follows this strategy |
| `CI_CD.md` | CI workflow setup follows these patterns |
