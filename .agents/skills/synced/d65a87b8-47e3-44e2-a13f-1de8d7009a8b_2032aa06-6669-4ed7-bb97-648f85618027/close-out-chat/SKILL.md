---
name: close-out-chat
description: "Gracefully close out a session before the user leaves. Use this skill whenever the user says 'close out,' 'wrap up,' 'before I go,' 'leaving this chat,' 'end of session,' 'sign off,' 'that's it for now,' 'I'm done,' 'session summary,' 'what did we do,' or any indication they're about to leave and want things tied up. Also trigger proactively when the user says goodbye, thanks you at the end of a long session, or says 'moving to a different chat.' Even casual signals like 'ok I think that's everything' or 'cool thanks' after a multi-step session should trigger this skill. The goal is to make sure nothing falls through the cracks — every session ends clean."
---

# Close Out Chat

Post-flight checklist. Nothing falls through the cracks.

## Sequence (skip steps that don't apply)

**1. Close open loops** — Flag unfinished todos, unsent drafts, open time entries, unanswered decisions.

**2. Inventory deliverables** — For each thing produced: what it is, clickable link, one line on when they'd use it.

**3. Save to memory** — Save new user context, corrections, project details, or references that would be lost when this conversation ends. Skip anything already in memory or derivable from files.

**4. Next steps** — One or two sentences on natural follow-up. No project plans.

**5. Present it** — Clean, scannable, warm, brief. "Here's where everything is, here's what's next, you're good to go."

## Rules

- No new ideas — they're leaving
- Deliverables and decisions only — not a conversation recap
- No long explanations — the user was there
- No questions — they're on their way out
