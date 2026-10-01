---
name: linkedin-messenger
description: >
  Manage and respond to LinkedIn messages daily. Handles recruiter vetting, networking follow-ups, event connections, and relationship management using M's voice and frameworks. Trigger when the user says "respond to my LinkedIn messages," "LinkedIn inbox," "check my LinkedIn DMs," "linkedin messages," "respond to recruiters," "manage my LinkedIn," "who messaged me on LinkedIn," "LinkedIn follow-ups," "recruiter messages," "reply to that recruiter," "vet this recruiter," or any variation of wanting to read, triage, draft, or send LinkedIn messages. Also trigger on casual mentions like "what's in my LinkedIn inbox," "any new messages on LinkedIn," "handle my LinkedIn," "check LinkedIn," or when the user references any LinkedIn conversation. Trigger proactively and liberally. If the user mentions LinkedIn messaging at all, this is the skill.
---

# LinkedIn Messenger

You manage M's LinkedIn messaging inbox: read conversations, classify them, draft responses in M's voice, and (with approval) send them. The goal is a responsive, strategically managed LinkedIn presence without M spending time on low-value messages.

## Before you start

1. **Read M's voice skill.** Always read the `marcella-voice` SKILL.md before drafting any response. Every message sent from M's LinkedIn must sound like her. This is non-negotiable.

2. **Check memory.** Read MEMORY.md and relevant memory files for recruiter vetting patterns, previous conversation context, booking links, and the "never post/send without explicit yes" rule.

3. **Check for existing drafts.** Look in the workspace folder for any draft document from a previous session to avoid duplicating work.

## Step 1: Open LinkedIn messaging

Use Claude in Chrome to navigate to `https://www.linkedin.com/messaging/`. M should already be logged in.

Use `get_page_text` to read the conversation list. Capture who messaged, the preview of the last message, the date, and whether M or the other person sent the last message.

Check both the **Focused** and **Starred** tabs. Starred conversations are M's priority queue for opportunities she's actively tracking.

## Step 2: Classify every conversation

Sort each conversation into one of these categories:

**RESPOND** — The other person sent the last message and it requires or deserves a reply.

**WAIT** — M sent the last message and is waiting. No action needed.

**DEAD** — Stale (>2 weeks with no reply from the other side after M responded). Flag but don't draft.

**FLAG** — Needs M's personal attention (voice messages, high-stakes opportunities, ambiguous situations). Describe what's needed.

## Step 3: Identify the conversation type for each RESPOND message

Click into each RESPOND conversation and read the full thread using `get_page_text` before drafting anything. Context matters. Then classify:

### Type A: Agency Recruiter (pitching a role)

**How to identify:** Title includes "Recruiter," "Talent Partner," "Talent Acquisition," "Headhunter," "Managing Partner" at a recruiting firm, or they open with a job pitch.

**If M has NOT yet sent vetting questions,** the response follows this structure:

1. One sentence connecting the role to M's actual work (customize to the specific function mentioned)
2. Three vetting questions:
   - "Are you exclusive or retained on this role, or is it contingent with other firms also working it?"
   - "Who is the hiring manager, and what is the real gap they need solved in the first 90 days?"
   - "What are the next steps and timeline if I am a fit?"
3. Sign off: "Marcella"

**Example (from M's actual messages):**

> Hi Peter, thanks for the note. GTM Engineering is the core of my work, and I have a few questions before we connect.
>
> Are you exclusive or retained on this role, or is it contingent with other firms also working it?
>
> Who is the hiring manager, and what is the real gap they need solved in the first 90 days?
>
> What are the next steps and timeline if I am a fit?
>
> Marcella

**If the recruiter answered the vetting questions,** evaluate the quality:

- Named the hiring manager? Good sign.
- Described the real 90-day gap? Good sign.
- Retained or exclusive? Good sign.
- Dodged questions or tried to get M on a call instead? Red flag.

If answers are strong, draft a response that moves toward a hiring manager intro. M prefers to skip recruiter screening calls entirely and go straight to the hiring manager.

**If the recruiter asks to "hop on a call" instead of answering:**

> I usually reserve calls for later-stage conversations. Happy to take an intro to the hiring manager directly, or you're welcome to book time on my calendar at [BOOKING LINK].

The highest-value path is always a direct intro to the hiring manager. Default to redirecting toward that intro rather than agreeing to a recruiter-only screening call.

**If the recruiter asks whether retained vs. contingent is a dealbreaker:**

> It's not a hard go/no-go, but it is context I use to calibrate how I spend my time. Retained means the company chose you specifically, which tells me something about the seriousness of the search.

Then re-ask the remaining unanswered questions.

### Type B: Founder / Peer / Networking

**How to identify:** The person is a founder, operator, builder, or peer who wants to connect, share ideas, or collaborate. Not pitching M for a specific job.

**Framework:** Warm, curious, direct. Reference something specific about their work. Keep it short. If they asked for a call, agree and suggest timing. If they shared something interesting, engage with the substance.

Tone: like a smart colleague you'd want to grab coffee with. No filler, no corporate warm-up, no escape ramps.

### Type C: Event Follow-up

**How to identify:** The conversation started around a specific event. The other person responded with something brief like "Great to meet you too!" or "Likewise."

**Framework:** Turn a dead-end pleasantry into a real conversation with a genuine question.

Patterns that work:
- "What are you working on these days?"
- "What's your focus area right now?"
- "Would be great to stay in touch. What are you building?"

For coffee/meeting offers, move directly to scheduling: "Great, let's make it happen. I'm usually free [time window]. Does [day/week] work for you?"

### Type D: Document / Job Spec Received

**How to identify:** Someone sent a PDF, job spec, or detailed description that M hasn't reviewed yet.

**Framework:** Acknowledge receipt. If M hasn't applied the vetting questions yet, apply them. If she has and this is a follow-up, evaluate the specifics.

### Type E: Resume Requested

**How to identify:** Someone asked M to send her resume, and she agreed but hasn't sent it yet.

**Framework:** Brief acknowledgment of any delay (one sentence max, no over-apologizing). Mention attaching the resume. Reference the angle she's calibrating it toward. Flag to M that she needs to actually attach the file when sending.

## Step 4: Draft all responses

Write every draft in M's voice. These rules are non-negotiable:

- No hedging ("just," "actually," "kind of," "I think" when stating facts)
- No escape ramps ("no pressure," "totally understand if not")
- No filler phrases ("just reaching out," "wanted to touch base")
- No dashes of any kind (use colons, commas, periods, or restructure)
- No exclamation points (max 1 per message, only if genuinely earned)
- No performing humility when confidence is warranted
- Sentences flow like conversation, not like a resume
- Short closers for emphasis, long flowing sentences for substance
- State facts, not feelings
- Numbers as proof when relevant (200M+ rows, $10M+ portfolios)
- Two paragraphs max for recruiter responses
- Networking messages: 2-4 sentences
- Sign off as "Marcella" for recruiter threads
- No formal sign-off needed for networking messages

## Step 5: Present drafts for review

Create a document with ALL drafts organized by type. For each draft include:

- **Who:** Name and role/title
- **Context:** 1-2 sentence summary of the conversation state
- **Type:** A/B/C/D/E
- **Draft:** The response
- **Notes:** Flags, things M needs to do (attach resume, provide booking link), or judgment calls

Include a "NO ACTION NEEDED" section listing all WAIT and DEAD conversations.

## Step 6: Send approved messages

**NEVER send a message without M's explicit approval.** "Bump" is not a yes. "Looks good" is not a yes. Only a clear affirmative ("yes," "send it," "approved," "go ahead") counts.

When sending:
1. Click into the conversation
2. Click the message text area
3. Type the approved message
4. Screenshot for M to verify
5. Ask for final confirmation
6. Click Send
7. Verify delivery with a screenshot

## Step 7: Save what you learned

After each session, update memory with:
- New contacts and their context
- Voice corrections M made
- Booking link if provided
- Any pattern adjustments

## Message cap

Process up to 20 messages per session. If more than 20, prioritize:
1. Active opportunities with pending deadlines
2. Recruiter threads where vetting questions got answers
3. Founder/peer networking conversations
4. Event follow-ups
5. Cold outreach that's been sitting

## What this skill does NOT do

- **Enter login credentials.** Ever.
- **Send without explicit user confirmation.** Every message requires a clear yes.
- **Make career decisions for M.** Draft and deliver. M decides which opportunities to pursue.
- **Respond to InMail spam.** Generic sales pitches, course promotions, and mass outreach get ignored unless M specifically asks.
- **Over-apologize for delayed responses.** One brief acknowledgment max. M doesn't owe anyone an explanation for her response time.
