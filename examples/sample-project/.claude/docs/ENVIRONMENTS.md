# Environment Management Approach

This document describes principles and patterns for managing development, test, and production environments. It emphasizes isolation, reproducibility, and production-awareness from day one.

## Core Philosophy

### The Problem with Shared Environments

Traditional development uses shared or singleton environments:

- One local Postgres instance for all work
- One "staging" server everyone deploys to
- Configuration that drifts between machines
- "Works on my machine" as a recurring problem

This creates:

- **Interference** - One workstream's DB changes break another
- **Contention** - Can't test migrations without coordinating
- **Drift** - Dev environment diverges from prod over time
- **Integration pain** - Conflicts discovered late, at merge time

### The Disposable Environment Model

Inspired by [Magerramov's "Disposable Environments, Durable Sessions"](https://blog.joemag.dev/2026/01/disposable-environments-durable.html):

```
┌─────────────────────────────────────────────────────────┐
│                 Environment Spec (durable)              │
│    Declarative definition: services, deps, config       │
└─────────────────────────────────────────────────────────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │  Feature A  │ │  Feature B  │ │  Feature C  │
    │  Instance   │ │  Instance   │ │  Instance   │
    │             │ │             │ │             │
    │ - postgres  │ │ - postgres  │ │ - postgres  │
    │ - node api  │ │ - node api  │ │ - node api  │
    │ - code      │ │ - code      │ │ - code      │
    └─────────────┘ └─────────────┘ └─────────────┘
         ▲               ▲               ▲
         │               │               │
    feature-a       feature-b       feature-c
      branch          branch          branch
```

**Key inversion:** The environment spec is the durable artifact. Instances are disposable.

## Principles

### 1. Environment as Code

The environment specification lives in the repository:

```
project/
├── docker-compose.yml       # Service definitions
├── .env.template            # Required variables (no secrets)
├── docker/
│   ├── postgres/
│   │   └── init.sql         # DB initialization
│   └── node/
│       └── Dockerfile       # App container
└── scripts/
    ├── env-up.sh            # Spin up environment
    ├── env-down.sh          # Tear down environment
    └── env-reset.sh         # Reset to clean state
```

**Why this matters:**

- New developers (or new workstreams) get identical environments
- Environment changes are code reviewed
- No hidden machine-specific configuration

### 2. One Branch, One Environment

Each feature branch gets its own isolated environment instance:

| Resource | Isolation Method |
|----------|------------------|
| Code | Git worktree per branch |
| Database | Separate Postgres container (unique port or name) |
| Services | Separate containers (unique ports) |
| Config | Branch-specific `.env` file |

**Naming convention:**

```
# Branch: feature-auth-redesign
# Worktree: ~/projects/myapp--auth-redesign
# Compose project: myapp-auth-redesign
# Postgres port: 5433 (or dynamic)
# API port: 3001 (or dynamic)
```

### 3. Production Parity

Development environments should mirror production structure, not just "work locally."

**Mirror these:**

- Database engine and version (Postgres 15, not SQLite)
- Service boundaries (if prod has separate API and worker, dev should too)
- Configuration shape (same env var names, different values)
- Auth mechanisms (even if using test credentials)

**Acceptable differences:**

- Scale (1 replica vs. many)
- External services (local mock vs. real AWS)
- Performance settings (lower resource limits)
- TLS (optional locally, required in prod)

**Anti-pattern:** Using SQLite locally "for simplicity" when prod uses Postgres. Migration day becomes debugging day.

### 4. Explicit Environment Differences

Don't hide differences—declare them:

```
# .env.template - documents ALL required variables
DATABASE_URL=              # postgres://user:pass@host:port/db
API_PORT=                  # Port for API server
LOG_LEVEL=                 # debug|info|warn|error
FEATURE_FLAGS=             # Comma-separated feature flags

# --- Environment-specific notes ---
# Dev: DATABASE_URL uses localhost, LOG_LEVEL=debug
# Prod: DATABASE_URL from secrets manager, LOG_LEVEL=info
```

### 5. PRs as Integration Point

With isolated environments, integration happens at PR merge:

```
feature-a (isolated) ──┐
                       ├──► PR ──► main ──► shared staging ──► prod
feature-b (isolated) ──┘
```

**Benefits:**

- No "who broke staging?" mysteries
- Parallel work without coordination
- Conflicts are explicit (merge conflicts, not runtime surprises)
- CI runs against the merged result

## Practical Setup (Node + Postgres)

### Directory Structure

```
~/projects/
├── myapp/                          # Main checkout (main branch)
│   ├── docker-compose.yml
│   ├── .env                        # Main branch env
│   └── ...
├── myapp--feature-auth/            # Worktree for auth feature
│   ├── .env                        # Auth feature env
│   └── ... (rest is linked)
└── myapp--feature-billing/         # Worktree for billing feature
    ├── .env                        # Billing feature env
    └── ...
```

### Docker Compose with Dynamic Naming

```yaml
# docker-compose.yml
services:
  postgres:
    image: postgres:15
    container_name: ${COMPOSE_PROJECT_NAME:-myapp}-postgres
    environment:
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-postgres}
      POSTGRES_DB: ${DB_NAME:-myapp}
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - ${COMPOSE_PROJECT_NAME:-myapp}-pgdata:/var/lib/postgresql/data

  api:
    build: .
    container_name: ${COMPOSE_PROJECT_NAME:-myapp}-api
    environment:
      DATABASE_URL: postgres://${DB_USER:-postgres}:${DB_PASSWORD:-postgres}@postgres:5432/${DB_NAME:-myapp}
      PORT: 3000
    ports:
      - "${API_PORT:-3000}:3000"
    depends_on:
      - postgres

volumes:
  ${COMPOSE_PROJECT_NAME:-myapp}-pgdata:
```

### Environment Setup Script

```bash
#!/bin/bash
# scripts/env-up.sh - Spin up isolated environment for current branch

BRANCH=$(git branch --show-current)
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-' | tr '[:upper:]' '[:lower:]')
PROJECT_NAME="myapp-${SAFE_BRANCH}"

# Find available ports
DB_PORT=$(scripts/find-port.sh 5432)
API_PORT=$(scripts/find-port.sh 3000)

# Create .env if missing
if [ ! -f .env ]; then
  cat > .env << EOF
COMPOSE_PROJECT_NAME=${PROJECT_NAME}
DB_PORT=${DB_PORT}
API_PORT=${API_PORT}
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=myapp
EOF
  echo "Created .env with ports: DB=${DB_PORT}, API=${API_PORT}"
fi

# Start services
docker compose up -d

echo "Environment ready:"
echo "  API: http://localhost:${API_PORT}"
echo "  DB:  localhost:${DB_PORT}"
```

### Port Discovery Script

```bash
#!/bin/bash
# scripts/find-port.sh - Find an available port starting from a base

BASE_PORT=${1:-3000}
PORT=$BASE_PORT

while lsof -i :$PORT >/dev/null 2>&1; do
  ((PORT++))
  if [ $PORT -gt $((BASE_PORT + 100)) ]; then
    echo "Error: No available port found in range $BASE_PORT-$PORT" >&2
    exit 1
  fi
done

echo $PORT
```

### Environment Teardown Script

```bash
#!/bin/bash
# scripts/env-down.sh - Tear down environment for current branch

if [ ! -f .env ]; then
  echo "No .env file found"
  exit 1
fi

# Load project name from .env
source .env

docker compose down

echo "Environment stopped: ${COMPOSE_PROJECT_NAME}"
```

### Environment Reset Script

```bash
#!/bin/bash
# scripts/env-reset.sh - Reset environment to clean state (destroys data)

if [ ! -f .env ]; then
  echo "No .env file found"
  exit 1
fi

source .env

echo "This will destroy all data for ${COMPOSE_PROJECT_NAME}. Continue? (y/N)"
read -r confirm
if [ "$confirm" != "y" ]; then
  echo "Aborted"
  exit 0
fi

docker compose down -v
rm .env

echo "Environment reset complete. Run ./scripts/env-up.sh to recreate."
```

### Git Worktree Workflow

```bash
# Create new feature environment
git worktree add ../myapp--feature-name feature-name
cd ../myapp--feature-name
./scripts/env-up.sh

# Work on feature...
# Environment is fully isolated

# Done with feature
cd ../myapp
git worktree remove ../myapp--feature-name
# Docker containers cleaned up separately or via env-down.sh
```

## Secrets Management

### Principles

1. **Never commit secrets** - Not even "dev" secrets
2. **Template, don't populate** - `.env.template` in repo, `.env` in `.gitignore`
3. **Document secret sources** - Where does each secret come from in prod?

### Local Development

```bash
# .env.template (committed)
DATABASE_URL=
API_KEY=
JWT_SECRET=

# .env (not committed, generated or copied)
DATABASE_URL=postgres://postgres:postgres@localhost:5432/myapp
API_KEY=dev-key-not-for-prod
JWT_SECRET=dev-secret-minimum-32-characters-long
```

### Production

Document where secrets come from:

```markdown
# docs/SECRETS.md

| Variable | Dev Source | Prod Source |
|----------|-----------|-------------|
| DATABASE_URL | Local .env | AWS Secrets Manager |
| API_KEY | Local .env | AWS Secrets Manager |
| JWT_SECRET | Local .env | AWS Secrets Manager |
```

## Testing Environments

### Unit Tests

Run against the current branch's environment:

```bash
# Uses whatever DB is running for this branch
npm test
```

### Integration Tests

Spin up fresh environment, run tests, tear down:

```bash
#!/bin/bash
# scripts/test-integration.sh - Run integration tests in isolated environment

set -e

TEST_PROJECT="myapp-test-$$"

cleanup() {
  docker compose -p "$TEST_PROJECT" down -v 2>/dev/null || true
}
trap cleanup EXIT

echo "Starting test environment: $TEST_PROJECT"
COMPOSE_PROJECT_NAME=$TEST_PROJECT docker compose up -d

echo "Waiting for services..."
sleep 5  # Or use a proper health check loop

echo "Running integration tests..."
DATABASE_URL="postgres://postgres:postgres@localhost:5432/myapp" \
  npm run test:integration

echo "Tests complete"
```

### CI Environment

CI creates its own isolated environment per run:

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/postgres
```

## Cloud Development Environments

The "one branch, one environment" principle extends to cloud-hosted development environments like GitHub Codespaces or Gitpod.

### When Cloud Environments Make Sense

| Scenario | Benefit |
|----------|---------|
| Resource-intensive work | Offload heavy builds to cloud hardware |
| Multi-machine workflow | Start on laptop, continue on desktop |
| Environment parity testing | Cloud is Linux; your laptop may be macOS |
| Sharing work in progress | Spin up a Codespace for someone to review |
| Parallel workstreams | Local for feature A, Codespace for feature B |

### Same Spec, Different Location

The environment spec (docker-compose.yml, .env.template) works identically:

```
┌─────────────────────────────────────────────────────────────────┐
│                    Environment Spec (in repo)                   │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
     ┌─────────────────┐             ┌─────────────────┐
     │  Local Machine  │             │   Codespaces    │
     │                 │             │                 │
     │  feature-a      │             │  feature-b      │
     │  environment    │             │  environment    │
     └─────────────────┘             └─────────────────┘
```

The environment is instantiated in different places, but the spec is the same.

### Working with Claude.ai

Claude.ai (web interface) works with any environment location—you provide context by pasting code, error messages, or architecture details.

**Effective workflow:**

1. Work in your environment (local or cloud)
2. When you need guidance, paste relevant context to Claude.ai
3. Apply Claude's suggestions in your environment
4. Iterate

**What to paste for good context:**

- Relevant code snippets (not entire files unless needed)
- Error messages with stack traces
- Architecture decisions you're considering
- Output of commands that aren't working

**What Claude.ai cannot do:**

- Access your environment directly
- Run commands or read files
- See what you're looking at

This is different from Claude Code (CLI), which can directly interact with local files and run commands.

### Codespaces Configuration

If using GitHub Codespaces, add a devcontainer configuration that references your existing docker-compose.yml:

```json
// .devcontainer/devcontainer.json
{
  "name": "Project Dev Environment",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "api",
  "workspaceFolder": "/workspace",
  "postCreateCommand": "npm install",
  "forwardPorts": [3000, 5432]
}
```

This reuses your environment spec rather than defining a separate one for Codespaces.

## Production Deployment Principles

Development environments should prepare you for production, not hide it. These principles guide production deployment.

### 1. Same Spec, Different Values

Production uses the same configuration shape as development:

```
┌─────────────────────────────────────────────────────────────────┐
│                    .env.template (shape)                        │
├─────────────────────────────────────────────────────────────────┤
│  DATABASE_URL=                                                  │
│  API_PORT=                                                      │
│  LOG_LEVEL=                                                     │
│  REPLICAS=                                                      │
└─────────────────────────────────────────────────────────────────┘
              │                               │
              ▼                               ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│  Development Values      │    │  Production Values       │
├──────────────────────────┤    ├──────────────────────────┤
│  localhost:5432          │    │  rds.amazonaws.com:5432  │
│  3000                    │    │  80                      │
│  debug                   │    │  info                    │
│  1                       │    │  3                       │
└──────────────────────────┘    └──────────────────────────┘
```

No variable should exist in prod that doesn't exist in dev (even if the value differs).

### 2. Infrastructure as Code

Production infrastructure should be as declarative as development environments:

| Layer | Tool Examples | Principle |
|-------|--------------|-----------|
| Containers | Docker, Kubernetes | Same images dev → prod |
| Orchestration | Kubernetes, ECS | Declarative desired state |
| Infrastructure | Terraform, Pulumi | Version-controlled, reviewable |
| Secrets | External Secrets, Vault | Injected at runtime, not baked in |

### 3. Kubernetes/Helm Principles

If deploying to Kubernetes:

**Use Helm charts that mirror your docker-compose.yml structure:**

```
helm/
├── Chart.yaml
├── values.yaml              # Default values (dev-like)
├── values-prod.yaml         # Production overrides
└── templates/
    ├── deployment.yaml      # Maps to docker-compose services
    ├── service.yaml
    └── configmap.yaml       # Maps to .env.template
```

**Principle: values.yaml should feel familiar:**

```yaml
# values.yaml
api:
  image: myapp-api
  port: 3000
  replicas: 1
  env:
    LOG_LEVEL: debug

postgres:
  image: postgres:15
  storage: 1Gi
```

If someone understands your docker-compose.yml, they should understand your Helm values.

**Production overrides, not rewrites:**

```yaml
# values-prod.yaml (only differences)
api:
  replicas: 3
  env:
    LOG_LEVEL: info

postgres:
  storage: 100Gi
```

### 4. Environment Progression

Code flows through environments with increasing confidence:

```
Local (isolated) → PR/CI → Staging → Production
     │                │         │          │
     │                │         │          └── Real traffic
     │                │         └── Near-prod, synthetic traffic
     │                └── Automated tests, ephemeral
     └── Manual testing, full isolation
```

**Each stage answers different questions:**

| Stage | Question Answered |
|-------|-------------------|
| Local | Does it work at all? |
| CI | Does it work with other changes merged? |
| Staging | Does it work in prod-like conditions? |
| Production | Does it work for real users? |

### 5. Rollback Capability

Production deployments must be reversible:

- **Container images are immutable** - Deploy v1.2.3, not "latest"
- **Database migrations are forward-only but safe** - No destructive changes without escape hatches
- **Feature flags for big changes** - Deploy dark, enable gradually
- **Keep previous version ready** - Kubernetes rollback, blue-green, etc.

## Alternative Approaches

Docker Compose is the recommended default, but alternatives exist:

### Devcontainers

Full development environment in a container, including editor tooling.

**Consider if:**
- You need reproducible CLI tools and language versions
- Your team uses VS Code
- Onboarding friction is high

**Trade-off:** More configuration complexity; editor coupling.

### Nix + direnv

Reproducible package management without containers for running services.

**Consider if:**
- You already know Nix
- You want lighter-weight isolation
- Bit-for-bit reproducibility matters

**Trade-off:** Steep learning curve; still need something for services.

### Local Services (no containers)

Install Postgres directly, run Node directly.

**Consider if:**
- Solo developer, single workstream
- Performance-sensitive (no container overhead)
- Simple project

**Trade-off:** No isolation; "works on my machine" risk; harder to match prod.

## Migration Strategy

### From Shared Local Environment

If you currently have one Postgres instance for everything:

1. **Export current schema** as baseline
2. **Create docker-compose.yml** with environment spec
3. **Test on one branch** - verify parity
4. **Adopt for new features** - old work can stay on shared DB
5. **Migrate gradually** - no big bang required

### Cleanup

Periodically remove stale environments:

```bash
# List all project containers
docker ps -a --filter "name=myapp-" --format "{{.Names}}"

# Remove containers for merged branches
docker compose -p myapp-feature-done down -v
```

## Relationship to Other Methodology Docs

| Document | Connection |
|----------|------------|
| `APPROACH.md` | Environment specs are declarative; aligns with "documentation as memory" principle |
| `CONTRIBUTING.md` | Environment changes should be documented; significant changes need ADRs |
| `ADR_TEMPLATE.md` | Use for decisions like "why Postgres over SQLite" or "why Docker over Nix" |
| `patterns/*.md` | Some patterns (e.g., DSL generation) have specific environment considerations |

## When to Write an ADR

Environment-related ADRs are appropriate for:

- Choosing primary database technology
- Choosing containerization approach (Docker, Nix, devcontainers)
- Significant changes to the isolation model
- Adding new services to the environment spec

Not needed for:

- Routine environment setup
- Adding environment variables
- Updating dependency versions
