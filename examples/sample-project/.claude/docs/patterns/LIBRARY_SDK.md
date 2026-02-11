# Library/SDK Pattern

> **Status: Draft** - Being developed through the UI Foundation extraction project.
> This pattern will be refined based on lessons learned.

This pattern covers building reusable libraries and SDKs for consumption by other developers. The key difference from application development: your users are developers, and your API is your product.

## When to Use This Pattern

**Good fit:**
- Reusable component libraries
- Utility packages
- API client SDKs
- Extracted shared code (like UI foundations)
- Any package published to npm/PyPI/etc.

**Characteristics:**
- Other developers are your users
- API stability and versioning matter
- Documentation is critical
- Breaking changes have real costs

## Core Principles

### 1. API Design First

Your public API is the product. Design it before implementation:

| Question | Why It Matters |
|----------|----------------|
| What's the simplest way to use this? | First impression determines adoption |
| What are the common cases? | Optimize for 80% use case |
| What are the escape hatches? | Power users need flexibility |
| What can change vs. what's locked? | Versioning strategy depends on this |

**Anti-pattern:** Implementing first, then exposing whatever internal API emerged.

### 2. Consumer-First Documentation

Documentation is not an afterthought. For libraries, docs are the UX:

| Doc Type | Purpose | When to Write |
|----------|---------|---------------|
| README | Quick start, installation, basic usage | First, before code |
| API Reference | Every public function/component | As you build |
| Examples | Common use cases, copy-paste ready | During development |
| Migration Guide | Upgrading between versions | With breaking changes |

**Principle:** If it's not documented, it doesn't exist.

### 3. Semantic Versioning

Follow semver strictly:

```
MAJOR.MINOR.PATCH

MAJOR - Breaking changes (consumers must update code)
MINOR - New features (backward compatible)
PATCH - Bug fixes (backward compatible)
```

**What counts as breaking:**
- Removing a public export
- Changing function signatures
- Changing default behavior
- Removing or renaming props/options

### 4. Minimal Dependencies

Every dependency is:
- A potential security vulnerability
- A version conflict waiting to happen
- Bundle size for your consumers

**Guidelines:**
- Zero dependencies is ideal
- Peer dependencies for frameworks (React, Vue)
- Vendor small utilities rather than importing them

### 5. Tree-Shakeable Exports

Let consumers import only what they need:

```typescript
// Good - named exports, tree-shakeable
export { Button } from './Button';
export { Card } from './Card';
export { Input } from './Input';

// Bad - barrel file that imports everything
export * from './components';
```

## Project Structure

```
ui-foundation/
├── src/
│   ├── components/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   └── index.ts
│   │   └── index.ts          # Named exports only
│   ├── hooks/
│   ├── utils/
│   ├── tokens/
│   │   ├── colors.ts
│   │   ├── spacing.ts
│   │   └── index.ts
│   └── index.ts              # Public API entry point
├── dist/                     # Built output
├── docs/                     # Documentation site
│   ├── getting-started.md
│   ├── components/
│   └── examples/
├── stories/                  # Storybook for development
├── package.json
├── tsconfig.json
├── README.md                 # Quick start
└── CHANGELOG.md              # Version history
```

## Extraction Process

When extracting from an existing project (like dashboard → ui-foundation):

### 1. Identify What's Generic

| Extract | Don't Extract |
|---------|---------------|
| Design tokens | App-specific tokens (brand colors) |
| Primitive components | Feature components |
| Utility hooks | Business logic hooks |
| Common patterns | One-off solutions |

### 2. Cut Dependencies

The extracted library should not depend on:
- The source project
- App-specific configuration
- Environment variables
- External services

### 3. Generalize Props

```typescript
// Before (app-specific)
interface ButtonProps {
  onClick: () => void;
  dashboardAction: DashboardAction;  // Too specific
}

// After (generic)
interface ButtonProps {
  onClick: () => void;
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
}
```

### 4. Add Extension Points

Make the library customizable without forking:

```typescript
// Theme provider for custom tokens
<ThemeProvider theme={customTheme}>
  <Button>Uses custom theme</Button>
</ThemeProvider>

// Component composition
<Button leftIcon={<CustomIcon />}>
  With custom icon
</Button>
```

## Testing Strategy

### Unit Tests

Test component behavior in isolation:

```typescript
describe('Button', () => {
  it('calls onClick when clicked', () => {
    const onClick = jest.fn();
    render(<Button onClick={onClick}>Click me</Button>);
    fireEvent.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalled();
  });
});
```

### Visual Regression

For component libraries, visual tests matter:

- Storybook for development and documentation
- Chromatic or Percy for visual regression in CI
- Snapshot tests as lightweight alternative

### Consumer Testing

Test that the library works when consumed:

```typescript
// In a separate test project
import { Button, Card } from 'ui-foundation';

// Verify imports work, types are correct, rendering works
```

## Publishing

### Package.json Essentials

```json
{
  "name": "@org/ui-foundation",
  "version": "1.0.0",
  "main": "dist/index.js",
  "module": "dist/index.mjs",
  "types": "dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    },
    "./tokens": {
      "import": "./dist/tokens/index.mjs",
      "require": "./dist/tokens/index.js"
    }
  },
  "files": ["dist", "README.md"],
  "peerDependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "sideEffects": false
}
```

### Build Configuration

Use a bundler that produces:
- ESM for modern bundlers
- CJS for Node.js/older tools
- Type declarations (.d.ts)
- Source maps

Common choices: tsup, Rollup, esbuild.

### Release Process

1. Update CHANGELOG.md
2. Bump version (npm version patch/minor/major)
3. Build and test
4. Publish (npm publish)
5. Create GitHub release with notes

## Documentation Site

For component libraries, a documentation site is essential:

| Section | Content |
|---------|---------|
| Getting Started | Installation, basic setup |
| Components | Props, examples, playground |
| Tokens | Colors, spacing, typography values |
| Theming | How to customize |
| Examples | Full use cases |

Tools: Storybook, Docusaurus, or custom Next.js site.

## ADRs for Libraries

Document these decisions:

| Decision | Why It Matters |
|----------|----------------|
| Bundle format | CJS vs ESM vs both |
| Styling approach | CSS-in-JS vs CSS variables vs Tailwind |
| React version support | What peer dependency range |
| Browser support | Which browsers to test |
| Breaking change policy | How often, deprecation period |

## Anti-Patterns

### 1. Exposing Internals

**Problem:** Internal helpers become public API by accident.
**Solution:** Explicit public exports only. Don't re-export everything.

### 2. Tight Framework Coupling

**Problem:** Library only works with specific framework version.
**Solution:** Peer dependencies with wide ranges. Test against multiple versions.

### 3. Documentation Rot

**Problem:** Docs don't match code after updates.
**Solution:** Generate API docs from code. Test examples in CI.

### 4. Breaking Without Bumping

**Problem:** Breaking changes in minor/patch versions.
**Solution:** Strict semver. Deprecation warnings before removal.

### 5. Kitchen Sink

**Problem:** Library grows to include everything.
**Solution:** Say no. Keep scope focused. Separate packages if needed.

---

## Notes for Refinement

This pattern will be updated as we build UI Foundation. Key questions to answer:

- [ ] Best tooling for building (tsup vs Rollup vs other)?
- [ ] How to handle CSS/styles in a library?
- [ ] Storybook vs custom docs site?
- [ ] Monorepo structure for multiple packages?
- [ ] Testing strategy for cross-browser/cross-React-version?
