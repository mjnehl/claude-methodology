# Pattern: AI-First Application Design

Design principles for applications where AI is central to the experience, not an add-on.

## When to Apply

Use this pattern when:
- Natural language is a primary input method
- The app should understand intent, not just commands
- Classification, suggestion, or interpretation is core
- Users should be able to "discuss" options with the system

## Spectrum of AI Integration

| Level | Description | Example |
|-------|-------------|---------|
| **AI-Enhanced** | Traditional UI + AI features | Search with smart suggestions |
| **AI-Forward** | AI shapes the primary workflow | Auto-categorization with human override |
| **AI-First** | AI is the primary interface | Natural language as main input |
| **AI-Native** | Designed assuming AI capabilities | No traditional forms, conversation only |

Most apps should target **AI-Forward** or **AI-First**.

## Core Principles

### 1. Natural Language as Primary Input

**Goal:** Users express intent in plain English; system interprets.

```
User types: "Buy milk tomorrow"
System creates:
  - Task: "Buy milk"
  - Due: tomorrow
  - Category: Groceries (inferred)
```

**Implementation:**
- Single text field for capture
- Parse intent, entities, dates, categories
- Confirm interpretation visually (not in dialog)
- Allow correction inline

**Anti-patterns:**
- Requiring structured input for simple things
- Forcing users to learn a syntax
- NLP that only works for exact phrases

### 2. Smart Classification with Discussion

**Goal:** AI classifies, user can discuss and refine.

```
User: "Call mom about birthday party"
AI: Categorized as "Personal > Family"
    Is this a task, a reminder, or an event?
User: "It's a reminder for Sunday"
AI: Got it. Reminder set for Sunday.
```

**Implementation:**
- Default classification applied automatically
- Show reasoning or confidence when helpful
- Allow conversational refinement
- Learn from corrections

**Anti-patterns:**
- Binary right/wrong classification
- No way to understand why it classified that way
- Requiring explicit correction commands

### 3. Proactive Suggestions

**Goal:** AI suggests next actions, patterns, improvements.

```
"You've added 3 grocery items today. Create a shopping list?"
"This looks similar to last month's 'Quarterly review' - same project?"
"You have 12 items due today. Want help prioritizing?"
```

**Implementation:**
- Suggestions are dismissible, not blocking
- Learn from accepted/rejected suggestions
- Context-aware (time, location, recent activity)
- Don't repeat rejected suggestions

**Anti-patterns:**
- Suggestions that interrupt flow
- Repeating the same unhelpful suggestion
- Suggestions that require immediate decision

### 4. Graceful Degradation

**Goal:** Works without AI, works better with AI.

- Core functionality doesn't require AI
- AI enhances but doesn't gate features
- Offline mode with AI features disabled
- Manual override always available

**Why:** AI services can be slow, unavailable, or wrong. The app should still work.

### 5. Transparency of AI Actions

**Goal:** User understands what AI did and can undo it.

```
[Task created] "Buy milk"
  📅 Tomorrow (inferred from "tomorrow")
  🏷️ Groceries (inferred from "milk")
  [Edit] [Undo]
```

**Implementation:**
- Show what was inferred vs. explicit
- Explain confidence when low
- Easy undo for AI actions
- History of AI decisions (for patterns)

### 6. Learning from Interaction

**Goal:** System improves with use.

- Remember correction patterns
- Adapt to user vocabulary
- Build user-specific models where appropriate
- Allow reset/retrain

**Privacy consideration:** Learning should be local unless explicitly synced.

## Implementation Guidelines

### Input Processing

```
Raw input: "remind me to call john at 3pm about the project"
↓
Parse:
  - Action: remind
  - Person: john
  - Time: 3pm (today inferred)
  - Topic: "the project" (may need clarification)
↓
Clarify if needed:
  "Which project - 'Website Redesign' or 'Q1 Planning'?"
↓
Create with full context
```

### Confidence Handling

| Confidence | Behavior |
|------------|----------|
| High (>90%) | Apply automatically, show result |
| Medium (60-90%) | Apply with visible "inferred" tag |
| Low (<60%) | Ask for clarification before applying |

### Conversation Memory

Within a session:
- Remember context ("it" refers to last item discussed)
- Allow follow-up refinements
- Support "actually, make that..." corrections

Across sessions:
- Remember preferences and patterns
- Don't require re-explaining context
- "Last time you did X, want to do that again?"

## AI Provider Integration

### Local vs. Cloud

| Approach | Pros | Cons |
|----------|------|------|
| Local (small model) | Fast, private, offline | Less capable |
| Cloud (large model) | More capable, better understanding | Latency, privacy, cost |
| Hybrid | Best of both | Complexity |

**Recommendation:** Start with cloud for capability, add local for speed/privacy on common operations.

### Prompt Design

- Include user's historical patterns in context
- Provide examples of desired output format
- Be specific about classification options
- Request structured output (JSON) for parsing

## Relationship to Other Patterns

- **ADHD_FRIENDLY.md** - AI reduces friction (fewer decisions, smart defaults)
- **FRONTEND_APP.md** - UI patterns for showing AI interpretations
- **CLI_TOOL.md** - NLP in CLI contexts

## Examples

### AI-First To-Do Entry

```
┌─────────────────────────────────────────────────┐
│ What do you want to do?                          │
│ ________________________________________________│
│                                                  │
│ "Buy groceries for dinner party Saturday"       │
│                                                  │
│ ✨ Creating task...                              │
│                                                  │
│ [✓] Buy groceries                               │
│     📅 Saturday (before dinner party)           │
│     🏷️ Shopping, Dinner Party                   │
│     💡 Related: "Dinner party prep" (3 tasks)   │
│                                                  │
│     [Looks good] [Edit] [Tell me more]          │
└─────────────────────────────────────────────────┘
```

### Classification Discussion

```
User: "Handle the Johnson situation"

AI: I'm not sure how to classify this. A few options:

    1. Task: "Handle Johnson situation" in Work
    2. Project: New project "Johnson situation"
    3. Note: Just capture it for later

    What fits best? Or tell me more about it.

User: "It's a client issue, make it a task for Monday"

AI: Got it.
    [✓] Handle Johnson situation
        📅 Monday
        🏷️ Work > Clients > Johnson
```

## Testing AI-First Features

1. **Ambiguity handling** - What happens with unclear input?
2. **Edge cases** - Unusual date formats, names, contexts
3. **Correction flow** - How easy to fix wrong interpretations?
4. **Learning validation** - Does it actually improve with use?
5. **Offline behavior** - Does core functionality still work?
6. **Speed perception** - Does it feel fast enough?
