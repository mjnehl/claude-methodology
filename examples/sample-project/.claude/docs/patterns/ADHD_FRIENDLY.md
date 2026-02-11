# Pattern: ADHD-Friendly Application Design

Design principles for applications that work with ADHD brains, not against them.

## When to Apply

Tag projects as `ADHD-aware` when they involve:
- Personal productivity or task management
- Habit tracking or routine building
- Planning (meals, health, schedule)
- Anything requiring sustained engagement over time

## Core Principles

### 1. Low Friction

**Goal:** Minimize steps between intention and action.

- One-tap/one-click primary actions
- Smart defaults that rarely need changing
- Capture first, organize later
- No mandatory fields beyond the essential
- Quick entry that doesn't interrupt flow

**Anti-patterns:**
- Multi-step wizards for simple actions
- Required categorization before saving
- Complex forms that lose half-finished input

### 2. Forgiveness

**Goal:** Missing a day (or week) doesn't break the system.

- No streak-shaming or guilt mechanics
- Easy to resume after a gap
- Historical gaps don't affect current functionality
- "Start fresh" option always available
- Accumulated incomplete items don't become overwhelming

**Anti-patterns:**
- Broken streak notifications
- Overdue badges that pile up
- Systems that require "catching up"

### 3. Gentle Reminders

**Goal:** Helpful nudges, not nagging.

- Context-aware timing (not 6am on weekends)
- Snooze that actually works
- Escalation only when requested
- Easy to adjust or disable
- Reminders include enough context to act

**Anti-patterns:**
- Fixed-time reminders that can't adapt
- Repeated notifications for the same thing
- Reminders that require opening the app to understand

### 4. Dopamine-Friendly

**Goal:** Visible progress and small wins.

- Celebrate completions (subtle, not annoying)
- Progress indicators that show momentum
- Break large tasks into visible chunks
- "Done" state feels satisfying
- Stats that show positive patterns, not failures

**Anti-patterns:**
- Only showing what's incomplete
- Giant task lists with no sense of progress
- Completion that feels anticlimactic

### 5. Flexible Structure

**Goal:** Adapts to how the brain works that day.

- Multiple valid ways to accomplish things
- Reordering and reprioritizing is easy
- Time estimates are optional, not required
- Categories/tags are suggestions, not requirements
- Works for both hyperfocus and scattered days

**Anti-patterns:**
- Rigid workflows that must be followed
- Hierarchies that require proper nesting
- Systems that assume consistent energy levels

### 6. Reduce Decision Fatigue

**Goal:** Fewer choices, smarter defaults.

- Limit options shown at once
- Suggest next actions based on context
- Remember preferences and patterns
- "Good enough" defaults that work without tweaking
- Hide advanced options until needed

**Anti-patterns:**
- Overwhelming settings pages
- Requiring decisions before allowing progress
- Showing all options all the time

## Implementation Guidelines

### Onboarding

- Start usable immediately, refine later
- Don't require full setup before first use
- Progressive disclosure of features
- Skip button always available

### Data Entry

- Voice input where possible
- Natural language parsing
- Photo/screenshot capture
- Templates for common entries
- Draft/incomplete states are first-class

### Notifications

- Batching over individual pings
- Summary notifications vs. per-item
- Quiet hours respected by default
- Action buttons in notifications (no app-opening required)

### Recovery

- Clear inbox/reset option
- Archive vs. delete (reversible)
- Bulk operations for cleanup
- "What did I miss" summary view

## Testing with ADHD in Mind

When evaluating ADHD-aware features:

1. **Simulate a bad day** - Does it still work when executive function is low?
2. **Simulate a gap** - Come back after a week. Is it welcoming or guilt-inducing?
3. **Count the taps** - How many actions to complete the most common task?
4. **Check the defaults** - Would it work without any configuration?
5. **Feel the friction** - Where do you hesitate or avoid?

## Examples

### Good: Quick Capture To-Do
```
[text field] [Add button]
```
One field. One button. Categorize later (or never).

### Bad: Full-Form To-Do
```
Title: [________]
Description: [________]
Due date: [________] (required)
Priority: [dropdown]
Category: [dropdown]
Tags: [multi-select]
[Cancel] [Save]
```
Seven decisions before you can save.

### Good: Missed Day Recovery
```
"Welcome back! You have 3 items from last week.
[Review] [Archive all] [Start fresh]"
```

### Bad: Missed Day Guilt
```
"You missed 5 days! Your streak is broken.
12 overdue items require attention."
```

## Relationship to Other Patterns

- Combine with `FRONTEND_APP.md` for UI implementation
- Consider `CLI_TOOL.md` for quick-capture CLI companions
- Privacy concerns from `PRIVACY.md` (when created) may affect notification strategies

## References

- ADHD-friendly design principles
- Reducing cognitive load in UX
- Habit formation research (make it easy, make it obvious, make it satisfying)
