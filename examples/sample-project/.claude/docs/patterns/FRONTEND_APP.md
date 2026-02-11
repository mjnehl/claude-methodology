# Frontend App Pattern

> **Status: Validated** - Refined through Personal Dashboard project.
> Tested design systems, widget patterns, and parallel agent development.

This pattern covers building frontend-heavy applications with rich UX, focusing on component architecture, design systems, and visual verification.

## When to Use This Pattern

**Good fit:**
- Single-page applications with rich interactivity
- Dashboard and data visualization apps
- Apps where UX/visual design is central
- Component-heavy interfaces (widgets, cards, modals)

**Characteristics:**
- Significant frontend logic and state
- Visual appearance matters
- Multiple interactive components
- Often paired with API backend

## Core Principles

### 1. Design System First

Before building features, establish:

| Element | What to Define | Why It Matters |
|---------|----------------|----------------|
| Colors | Primary, secondary, semantic (error, success) | Consistency across components |
| Typography | Font families, sizes, weights, line heights | Readable, hierarchical content |
| Spacing | Base unit, scale (4px, 8px, 16px...) | Consistent rhythm and alignment |
| Components | Button, input, card, modal primitives | Reusable building blocks |

**Anti-pattern:** Building features with ad-hoc styles, then "cleaning up later."

### 2. Component Architecture

Structure components in layers:

```
components/
├── primitives/         # Atomic elements (Button, Input, Text)
│   ├── Button.tsx
│   └── Input.tsx
├── composites/         # Combinations (Card, Modal, Form)
│   ├── Card.tsx
│   └── Modal.tsx
├── features/           # Domain-specific (WeatherWidget, TodoList)
│   ├── WeatherWidget/
│   └── TodoList/
└── layouts/            # Page structures (DashboardLayout, Sidebar)
    └── DashboardLayout.tsx
```

**Dependency rule:** Features depend on composites, composites depend on primitives. Never reverse.

### 3. State Management Strategy

Choose based on scope:

| State Type | Scope | Solution |
|------------|-------|----------|
| UI state | Component | `useState`, component props |
| Feature state | Feature subtree | Context, feature store |
| App state | Global | Zustand, Redux, or global context |
| Server state | Cached API data | React Query, SWR |

**Principle:** Keep state as local as possible. Lift only when necessary.

### 4. Visual Verification

The hard problem: how do you verify "it looks right"?

Approaches:

| Approach | What It Catches | Limitations |
|----------|-----------------|-------------|
| Snapshot tests | Unintended changes | Brittle, easy to ignore diffs |
| Visual regression (Percy, Chromatic) | Pixel-level changes | Cost, CI complexity |
| Storybook + review | Component isolation | Manual, not automated |
| E2E screenshots | Full page appearance | Slow, flaky |

**Recommendation:** Start with Storybook for component development. Add visual regression for critical paths if needed.

### 5. Responsive Design

Design for breakpoints explicitly:

```typescript
const breakpoints = {
  sm: '640px',   // Mobile
  md: '768px',   // Tablet
  lg: '1024px',  // Desktop
  xl: '1280px',  // Large desktop
};
```

**Test at each breakpoint.** Don't assume "it probably works on mobile."

## Project Structure (Next.js)

```
dashboard/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx          # Root layout
│   │   ├── page.tsx            # Home page
│   │   └── api/                # API routes
│   ├── components/
│   │   ├── primitives/
│   │   ├── composites/
│   │   ├── features/
│   │   └── layouts/
│   ├── lib/                    # Utilities, hooks
│   │   ├── hooks/
│   │   └── utils/
│   ├── styles/                 # Global styles, design tokens
│   │   ├── tokens.css
│   │   └── globals.css
│   └── types/                  # TypeScript types
├── public/                     # Static assets
├── stories/                    # Storybook stories
└── tests/
    ├── unit/
    ├── integration/
    └── e2e/
```

## Widget Pattern (for Dashboards)

Dashboards have a specific pattern: **widgets**.

### Widget Contract

Every widget should implement:

```typescript
interface Widget {
  id: string;
  title: string;
  // Size constraints
  minWidth?: number;
  minHeight?: number;
  // Data requirements
  refreshInterval?: number;
  // Component
  component: React.ComponentType<WidgetProps>;
}

interface WidgetProps {
  width: number;
  height: number;
  onError?: (error: Error) => void;
}
```

### Widget Responsibilities

| Widget Handles | Framework Handles |
|----------------|-------------------|
| Fetching its own data | Layout and positioning |
| Rendering content | Error boundaries |
| Loading states | Resize events |
| Internal interactivity | Widget chrome (title bar, actions) |

## Testing Strategy

### Unit Tests

Test component logic and rendering:

```typescript
describe('WeatherWidget', () => {
  it('displays temperature when data loads', async () => {
    render(<WeatherWidget location="NYC" />);
    await waitFor(() => {
      expect(screen.getByText(/72°F/)).toBeInTheDocument();
    });
  });
});
```

### Storybook Stories

Document component states:

```typescript
export const Default: Story = {
  args: { location: 'New York' },
};

export const Loading: Story = {
  args: { location: 'New York' },
  parameters: { mockData: { loading: true } },
};

export const Error: Story = {
  args: { location: 'Invalid' },
  parameters: { mockData: { error: 'Location not found' } },
};
```

### E2E Tests

Test critical user flows:

```typescript
test('user can add a widget to dashboard', async ({ page }) => {
  await page.goto('/');
  await page.click('[data-testid="add-widget"]');
  await page.click('[data-testid="widget-weather"]');
  await expect(page.locator('.weather-widget')).toBeVisible();
});
```

## UX Decisions to Document

When building a frontend app, document these in ADRs:

| Decision | Options | Impact |
|----------|---------|--------|
| State management | Context vs. Zustand vs. Redux | Complexity, bundle size |
| Styling approach | CSS Modules vs. Tailwind vs. styled-components | DX, performance |
| Component library | Build custom vs. use Radix/shadcn | Speed vs. control |
| Data fetching | React Query vs. SWR vs. manual | Caching, complexity |
| Routing | App Router vs. Pages Router (Next.js) | Features, mental model |

## Parallel Development

For larger apps, enable parallel work:

### Foundation Phase

One agent establishes:
- Design system (tokens, primitives)
- Layout system
- Widget framework
- API patterns
- Storybook setup

### Feature Phase

Multiple agents build features in parallel:
- Each owns a feature directory
- Uses only established primitives/composites
- Adds stories for new components
- Writes tests for feature logic

**Coordination points:**
- Shared types in `types/`
- New primitives need foundation approval
- API schema changes need coordination

## Anti-Patterns

### 1. Style Soup

**Problem:** Ad-hoc styles everywhere, no consistency.
**Solution:** Design system with tokens. Lint for magic values.

### 2. Component Explosion

**Problem:** 200 components, unclear boundaries.
**Solution:** Clear component layers. Feature folders for domain components.

### 3. God Components

**Problem:** One component does everything (fetching, logic, rendering).
**Solution:** Separate concerns. Container/presentational split or hooks.

### 4. Ignoring Loading/Error States

**Problem:** Only happy path is implemented.
**Solution:** Design loading and error states first. Make them part of the spec.

### 5. "We'll Make It Responsive Later"

**Problem:** Desktop-only, then panic before launch.
**Solution:** Mobile-first or test breakpoints continuously.

---

## Notes for Refinement

This pattern will be updated as we build Personal Dashboard. Key questions to answer:

- [ ] What's the right balance of Storybook vs. E2E for visual verification?
- [ ] How to structure widget data fetching (per-widget vs. aggregated)?
- [ ] How to handle widget layout persistence (localStorage, DB)?
- [ ] What's the best coordination pattern for parallel feature development?
- [ ] How to document UX decisions (ADRs? Something else?)

## Future Consideration: Shared UI Foundation

**Observation (2026-01-23, from Personal Dashboard):** The foundation phase produces components that look highly reusable across frontend projects:

| Potentially Generic | Dashboard-Specific |
|--------------------|--------------------|
| Design tokens (colors, spacing, typography) | Widget framework |
| Primitives (Button, Input, Card, Text) | WidgetGrid, WidgetContainer |
| Composites (Modal, Dropdown, Tooltip) | Dashboard layout |
| Storybook setup | Widget positioning/state |
| API patterns | |

**Decision:** Wait to extract. Following the SERVICE_DEVELOPMENT principle of "build 2-3 direct first, then extract when stable."

**Why wait:**
- Dashboard is our first frontend project
- Don't yet know what the next frontend project needs
- Primitives may need adjustment based on real usage
- Premature extraction creates maintenance burden

**When to revisit:**
- When starting the next frontend project (e.g., Full-stack CRUD)
- Compare what's needed vs. what Dashboard built
- Extract only what's proven stable and truly shared

**What to extract (when ready):**
- Design tokens as CSS variables / Tailwind config
- Primitive components with Storybook stories
- Composite components
- Testing setup and patterns
- Possibly: a `create-ui-foundation` generator

This note ensures the insight isn't lost. The extraction decision should be revisited with real data from a second project.
