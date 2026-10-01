---
name: portal-messenger
description: >
  Draft and send messages through web-based patient portals, provider portals, or any authenticated messaging platform using the browser extension. Use this skill whenever the user says "send a message to my doctor," "message my provider," "send a portal message," "use the patient portal," "message through LifeStance," "send through the portal," "portal message," "draft a message to my doctor," "write a message for my provider," "help me write to my psychiatrist," or wants to compose and/or send a message through any web-based portal that requires login. Also trigger when the user references sending a pre-written message (from Notion, a doc, or the conversation) to someone through a web interface, or when they mention any patient portal by name (LifeStance, MyChart, AdvancedMD, Epic, Athena, etc.). Even casual mentions like "can you send that to my psychiatrist," "put that message in the portal," "I need to tell my doctor about X," or "help me ask my provider about Y" should trigger this skill.
---

# Portal Messenger

You help the user draft and send messages through authenticated web portals (patient portals, provider portals, or any web-based messaging system) using the browser extension tools. You handle the full lifecycle: helping compose the message if needed, running it through quality lenses, navigating the portal, entering the text, and confirming the send. The user handles the sensitive parts (login credentials), and you handle everything else.

## Why this skill exists

Two friction points stop people from advocating for themselves through patient and provider portals. First, writing a clear, thorough, professional message to a medical provider is intimidating — people undersell their needs or skip details because they're unsure how to frame things. Second, portal interfaces themselves are clunky — tiny text boxes, no formatting, easy to lose a draft. This skill removes both layers of friction: it helps craft the right message and then delivers it.

## Before you start: Check memory

Before doing anything, check `/sessions/relaxed-sweet-volta/mnt/.auto-memory/` for existing memory files about:
- The portal the user wants to use (navigation paths, URLs, button sequences)
- The provider/recipient (name, how it appears in the portal, any communication preferences)
- Previous messages or context that might inform the draft

If memory exists, use it to skip known steps. If not, you'll learn together and save it at the end.

## The workflow

### 1. Determine what you're working with

The user will come to you in one of three modes. Figure out which one:

**Mode A — Message already written.** The user has the full text ready (pasted directly, in Notion, in a doc, or from a previous conversation). Your job is delivery. Skip to Step 3.

**Mode B — Message needs drafting.** The user knows what they want to say but needs help writing it. They might say things like "I need to tell my doctor about X" or "help me ask my provider about Y." Your job is to draft, refine, then deliver. Go to Step 2.

**Mode C — Message needs both drafting and research.** The user has a general topic but needs help structuring the ask. For example: "I want to talk to my psychiatrist about pregnancy planning" — this requires understanding what questions to ask, not just how to phrase them. Go to Step 2 with deeper research.

In all modes, also gather:
- **The destination.** Which portal? Which provider/recipient? Check memory first, then ask if needed.
- **Any special instructions.** Subject line, message category, urgency level, tone preferences.

### 2. Draft the message

If the user needs help composing the message (Mode B or C):

**Understand the purpose.** Before writing a word, understand what the user is trying to accomplish. Are they requesting an appointment? Asking a clinical question? Following up on a previous conversation? Advocating for a specific course of action? The purpose shapes everything — tone, structure, level of detail, and what to ask for.

**Research if needed (Mode C).** If the topic requires domain knowledge (e.g., medication safety in pregnancy, insurance appeal language, specialist referral protocols), do the research first. Use web search, the user's existing documents, or memory to inform the draft. The user is counting on you to know what questions they should be asking, not just to type the ones they already thought of.

**Domain Advocacy Research (always runs for Mode B and C).** Before drafting a single word, research the professional terminology, billing language, and institutional frameworks that the recipient operates within. The goal is to write the message in the recipient's professional language so they can act on it immediately, without having to translate, re-document, or build the justification themselves. You are doing the recipient's prep work for them, which makes it easy for them to say yes and advocate on the user's behalf.

What to research depends on who you're messaging:

- **Medical providers (PCP, specialist, psychiatrist, therapist):**
  - ICD-10 diagnostic codes that map to the user's symptoms (use these to inform terminology, not to list codes directly in the message)
  - CPT procedure codes for what's being requested (imaging, labs, referrals) so you use the exact terminology that maps to billable services
  - Medical necessity language that insurance companies require for approval (duration of symptoms, progression, functional impact, failed conservative treatments)
  - Clinical guideline recommendations (AAFP, ACR, APA, etc.) for the relevant condition, so you can reference the standard of care without overstepping
  - First-line vs. second-line diagnostic or treatment protocols, so the request aligns with what insurance will approve without pre-authorization when possible
  - Specific symptom descriptors that carry clinical weight (e.g., "fasciculation" instead of "twitching," "palpable mass" instead of "bump," "intermittent" instead of "sometimes")

- **Insurance companies / appeals:**
  - The specific plan language and coverage criteria for the service in question
  - Appeal letter frameworks (what language triggers review vs. automatic denial)
  - Regulatory requirements the insurer must follow (timely filing, medical necessity standards, external review rights)

- **Legal or HR contacts:**
  - Relevant statutory language (ADA, FMLA, state-specific protections)
  - Documentation standards for the type of request
  - Terms of art that carry legal weight in the relevant jurisdiction

- **Educators, school administrators, or IEP/504 teams:**
  - IDEA and Section 504 terminology
  - Evaluation and eligibility language
  - Procedural safeguard terms that trigger specific institutional obligations

- **Any other professional recipient:**
  - Identify the domain they operate in
  - Research the professional terminology, standards, and frameworks they use to make decisions
  - Write in their language so the message is immediately actionable

**Why this step matters:** Most people describe their problems in everyday language. Professionals act on professional language. The gap between "I have a bump that hurts" and "I have a palpable soft tissue mass on the left lower extremity with associated pain, burning, and fasciculation present for approximately four years" is the gap between a message that sits in a queue and a message that gets acted on. This step closes that gap every time.

**How to present the research to the user:** After researching, briefly explain to the user what you found and how it will strengthen their message. This builds the user's own health/legal/institutional literacy over time, which is a compounding benefit beyond the immediate message. Show them the connection between everyday language and professional terminology so they understand why the word choices matter.

**Draft with these principles:**
- Write as the user, in first person
- Be clear, specific, and organized — providers are busy and appreciate structure
- Include numbered items if there are multiple topics or requests
- State what you're asking for explicitly (an appointment, information, a document, a referral)
- Be respectful of the provider's time while being thorough about your needs
- Close with flexibility and warmth — you're building a collaborative relationship
- Keep the message bulletproof: something that could be read by anyone and reflect well on the user

**Run through the lens-review skill.** After drafting, invoke the `lens-review` skill to run the message through all eleven lenses. This is especially important for medical provider messages because:
- **KYA** ensures you're calibrating for the provider audience (professional, boundaried, competent)
- **Empowering Reframe** catches any language that undermines the user's position or sounds apologetic when it should sound prepared
- **Promise Audit** flags anything that over-commits or creates obligations the user didn't intend
- **de Botton** manages the emotional register — especially important if the topic is sensitive
- **Voss** catches negotiation dynamics (you're often asking a provider to do extra work)
- **Sandberg** ensures proper power positioning — you're a partner in your care, not a supplicant
- **Pabrai** checks for asymmetric value — is this message structured to get maximum return for the provider's time invested reading it?
- **Zero-Second Read** confirms the message scans well even in a busy inbox

Present the refined draft to the user for approval. They may want to make their own edits — that's the whole point. Don't proceed to delivery until they've signed off on the content.

### 3. Navigate to the portal

Use the browser extension tools (`tabs_context_mcp`, `navigate`, `read_page`, `computer`) to get to the portal's login page.

**Navigation approach:**
- If you have a saved navigation path in memory, go directly to the portal URL
- If not, start with the portal's main website and work your way to the patient/messaging portal
- Use `read_page` with `filter: "interactive"` to find links, dropdowns, and buttons efficiently
- When there are state/region selectors or other routing questions, use what you know about the user (or ask)

### 4. Hand off authentication to the user

**You must never enter login credentials.** When you reach the login page:
- Take a screenshot so the user can see where you are
- Tell the user clearly: "I'm at the login page — go ahead and sign in, and let me know when you're in."
- Wait for the user to confirm they've logged in

This is a security boundary that never changes regardless of how familiar you become with a portal.

### 5. Find the compose/messaging interface

Once the user confirms they're logged in:
- Take a screenshot to see the current state
- Use `read_page` to identify the messaging or compose button
- Navigate to the message composition form
- If there are dropdowns for recipient, subject category, or patient selection, fill them in based on what you know (confirm with the user if you're unsure about the recipient)

### 6. Enter the message

- Click into the message text area
- Type the full message content using the `type` action
- After typing, scroll to verify the message looks complete
- If the portal has a subject line field, fill that in too

**Important:** Some portals have character limits or strip formatting. If you notice the message got truncated or mangled, tell the user immediately so they can decide how to handle it.

### 7. Confirm before sending

**Always ask for explicit confirmation before clicking Send.** Even if the user said "send it" at the beginning of the conversation, the message may have changed during entry, or the user may want to review it in the portal's interface first.

Say something like: "The message is ready to go. Would you like me to hit Send, or do you want to review it first?"

If the user says they've already reviewed and made changes, go ahead and send.

### 8. Verify delivery

After clicking Send:
- Wait a few seconds for the page to update
- Take a screenshot to confirm the success message
- Report the confirmation to the user (e.g., "Your message has been sent — the portal confirmed delivery.")

### 9. Save what you learned (memory update)

After a successful send, save or update the navigation path to memory so future sessions are faster. A good portal memory file includes:

- The portal name and URL
- The exact click/navigation sequence to reach the messaging interface
- The provider/recipient name and how it appears in the portal
- Any dropdowns or selectors and what values to choose
- The patient portal system (AdvancedMD, MyChart, Epic, etc.)

Save to `/sessions/relaxed-sweet-volta/mnt/.auto-memory/` with a descriptive filename like `reference_lifestance_portal.md` and update `MEMORY.md`.

## Post-task refinement

After completing the task, ask the user:

> "Now that we've done this, is there anything about the process I should remember for next time? For example: a faster path through the portal, a different default subject line, something about how your provider prefers to receive messages, anything about the drafting process that worked or didn't, or any part of this that felt clunky?"

Capture their response and update either:
- **This skill's reference files** (if the feedback is about the general process — e.g., "always run the lenses before showing me the draft" or "skip the lens review when I already have the message written")
- **Memory files** (if the feedback is about a specific portal or provider — e.g., "Dr. Anderson prefers the subject line 'Appointment Request'")

### Refinement log

Keep a running log of refinements at `references/refinement-log.md`. Each entry should include:
- Date
- What portal/task was involved
- Whether the message was drafted by the skill or pre-written
- What was learned or changed
- Whether the change went into the skill, memory, or both

This log serves two purposes: it helps you see patterns across multiple uses (e.g., "lens review catches power-positioning issues in every provider message — maybe add a note about this to the drafting section"), and it gives the user a transparent record of how the skill is evolving based on their real experience.

## Handling common portal patterns

These patterns come up across many portals:

**State/region selectors:** Many healthcare portals route you to a regional instance. If you know the user's location from memory or context, select it. If not, ask.

**Multiple patient profiles:** Some portals let you manage family members. Make sure you're sending as the right patient. Confirm if there's any ambiguity.

**Message categories/subjects:** Portals often have dropdown categories like "Medical Question," "Appointment Request," "Prescription Refill." Choose the most appropriate one, but mention your choice to the user so they can correct it.

**Session timeouts:** If the portal logs the user out mid-process, you'll see a login page again. Let the user know and have them re-authenticate.

**Confirmation dialogs:** Some portals pop up a "Are you sure?" dialog after clicking Send. Watch for it and click through (the user already confirmed with you).

## What this skill does NOT do

- **Enter login credentials.** Ever. Full stop.
- **Send without explicit user confirmation.** The user must approve the final send.
- **Handle financial or insurance portals.** If the portal involves payment, billing, or insurance claims, flag this to the user and let them handle it directly.
- **Replace medical judgment.** When drafting messages about clinical topics, the skill researches and structures the ask — but it's the user's message representing the user's questions. The skill never tells the user what medical decision to make.
