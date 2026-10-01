---
name: inbox-cleanup
description: >
  On-demand Gmail inbox cleanup using the Eisenhower Matrix. Trigger when the user says
  "inbox cleanup," "clean my inbox," "email triage," "process my inbox," "inbox zero,"
  "sort my emails," "triage emails," "clean up email," "deal with my inbox," or any
  variation of wanting their Gmail inbox organized, archived, labeled, and responded to.
  Also trigger when the user says "too many emails," "inbox is a mess," "email overwhelm,"
  or casually mentions needing to get through their email. This skill handles the full
  pipeline: Eisenhower Matrix classification, label application, Q4 archival, and
  lens-reviewed draft responses. Trigger proactively and liberally.
---

# Inbox Cleanup

You're running M's inbox cleanup process. This is a repeatable system that takes a messy
inbox and leaves it organized, labeled, triaged, and with draft responses queued up for
anything that needs a reply. The entire process runs through the Eisenhower Matrix.

## Which Gmail Account?

M has two Gmail accounts. **Always ask M which inbox she wants cleaned before starting.**
Use `AskUserQuestion` with the two options so she can pick with one click:

- **marcellamay21@gmail.com** — requires Chrome browser tools (`computer`, `navigate`,
  `get_page_text`). Use the browser-based labeling workflow described below.
- **marcella@marcella.dev** — uses the Gmail MCP (`gmail_search_messages`,
  `gmail_create_draft`, etc.) for searching and drafting. Labeling and archiving require
  Chrome browser (see Known Limitations below).

If only one set of tools is available, still confirm with M — she may want to wait for
the right environment rather than clean the wrong inbox.

---

## Known Limitations & Workarounds (Learned Apr 2026)

### Gmail MCP Tool Gaps

The Gmail MCP connector has these tools: `gmail_search_messages`, `gmail_read_message`,
`gmail_read_thread`, `gmail_create_draft`, `gmail_list_drafts`, `gmail_list_labels`,
`gmail_get_profile`.

**Missing tools (not available despite being referenced):**

- `gmail_modify_thread` — Referenced in `gmail_list_labels` description but DOES NOT
  EXIST. Cannot apply labels or remove INBOX label via MCP.
- `gmail_delete_draft` — No way to delete drafts via MCP.
- `gmail_send_draft` — Referenced in `gmail_create_draft` description but may not exist.
  Verify before relying on it.

**Consequence:** For marcella.dev, use MCP for scanning and draft creation only. All
labeling, archiving, and draft deletion must go through Chrome browser.

### Chrome Browser Workarounds

These workarounds were discovered through trial and error. Use them instead of the naive
approaches that will silently fail:

1. **Archiving — JavaScript `.click()` and MouseEvent dispatch BOTH silently fail.**
   The standard `div[act="7"].click()` and full MouseEvent dispatch sequences (mousedown,
   mouseup, click) appear to work but the archive doesn't persist. Gmail doesn't trust
   synthetic events for destructive actions.

   **What actually works:**
   - **Single email (viewing inside a thread):** Keyboard shortcut `e` via KeyboardEvent
     dispatch on `document`. Must dispatch all three events (keydown, keypress, keyup),
     all with `bubbles: true`:
     ```javascript
     ['keydown', 'keypress', 'keyup'].forEach(type => {
       document.dispatchEvent(new KeyboardEvent(type, {
         key: 'e', code: 'KeyE', keyCode: 69, which: 69, bubbles: true
       }));
     });
     ```
   - **Bulk from list view (after selecting checkboxes):** Click the Archive toolbar button
     using `mcp__Claude_in_Chrome__computer` `left_click` at the button's screen coordinates.
     Take a screenshot first to find the button location. The keyboard shortcut `e` does
     NOT work for bulk selections in list view.
   - **Always verify after archiving.** Reload the inbox and take a screenshot. Gmail
     caches aggressively. The API (`gmail_search_messages`) returns stale results for
     minutes after Chrome-based archiving. The Chrome inbox view is the source of truth.

2. **Checkbox selection — JavaScript `.click()` on `div[role="checkbox"]` is unreliable.**
   Gmail sometimes doesn't register the selection state from synthetic clicks, even though
   the checkbox visually appears toggled.

   **What works:** Click each checkbox at its screen coordinates using
   `mcp__Claude_in_Chrome__computer` `left_click`. The checkbox column is at approximately
   x=362 on each row. Always screenshot after selecting to confirm the checked state before
   proceeding with label or archive operations.

3. **Label + Archive must be two separate operations.** After applying a label, Gmail
   clears the checkbox selections. You must re-select the emails before archiving. Never
   try to chain label and archive in a single setTimeout sequence — the archive step will
   silently drop.

   **Label application flow (via coordinate clicks):**
   1. Select email checkbox(es) via coordinate clicks
   2. Click the Labels toolbar button (tag icon, `data-tooltip="Labels"`) via coordinates
   3. Wait for the dropdown to appear (take a screenshot to verify)
   4. Find the correct `div[role="menuitemcheckbox"]` matching the label name and click it
   5. Find the `div[role="menuitem"]` with text "Apply" and click it
   6. **Re-select the same emails** (selection was cleared)
   7. Click the Archive toolbar button via coordinates

4. **Gmail search via URL hash does not filter:** Navigating to
   `#search/in%3Ainbox+from%3Aexample.com` shows ALL inbox results instead of filtering.
   `form.submit()` and Enter key dispatch also fail. **Workaround:** Abandon URL-based
   search filtering. Instead, scan the full inbox list and identify target emails by their
   position/row index, or use MCP search to get message IDs first.

5. **Draft compose body — innerHTML blocked:** Gmail's TrustedHTML policy blocks
   `composeBody.innerHTML = '...'` and `document.execCommand('insertHTML', ...)`.
   **Workaround:** Use:

```javascript
const compose = document.querySelector('div[contenteditable="true"][role="textbox"]');
compose.focus();
document.execCommand('selectAll', false, null);
document.execCommand('delete', false, null);
document.execCommand('insertText', false, 'new text here');
```

   Note: This produces double-spaced paragraphs (extra blank lines between paragraphs).
   This is acceptable and expected.

6. **Gmail account routing:**
   - marcella.dev = `/mail/u/1/` (secondary)
   - marcellamay21@gmail.com = `/mail/u/0/` (primary)
   Always verify the correct `/u/N/` path before navigating.

7. **Sending emails via Chrome:** The Send button `.click()` via JavaScript DOES work
   (unlike Archive). Navigate to the thread containing the draft — the compose area will
   auto-open. Replace content with `document.execCommand`, then:
   ```javascript
   document.querySelector('div[role="button"][data-tooltip*="Send"]').click();
   ```
   If you need to undo, the Undo banner appears briefly — click `span#link_undo` immediately.
   **Always wait for M's explicit "send" confirmation before clicking Send.**

8. **Opening drafts for editing:** Navigate to `#all/MESSAGE_ID` using the specific draft
   message ID (not the thread ID). This opens the thread with the compose area expanded.
   If no compose area appears, the draft may be collapsed — try clicking on the draft
   message element in the thread view.

9. **Large threads exceed token limits.** `gmail_read_thread` can return 100KB+ payloads
   that blow the context window. Save the result to a temp file and use Python to extract
   just the draft messages and the most recent non-draft message for context:
   ```python
   import json
   data = json.load(open('thread.txt'))
   text = data[0]['text']
   parsed = json.loads(text)
   for msg in parsed['messages']:
       if 'DRAFT' in msg.get('labelIds', []):
           print(msg['headers']['Date'], msg['body'][:500])
   ```

10. **Gmail API cache is stale after Chrome actions.** After archiving via Chrome,
    `gmail_search_messages` with `in:inbox` returns stale results for several minutes.
    Never rely on the API to verify archive success. Reload the Chrome inbox and screenshot.

### Pagination

`gmail_search_messages` maxResults caps at 500. For inboxes larger than 500, use
`nextPageToken` to paginate through all results. Always complete the full scan before
classifying — partial scans lead to missed Sacred Exceptions.

---

## Step 1: Scan the Inbox

Pull all inbox messages. Get a full picture before taking any action.

**Via Gmail MCP:**
Use `gmail_search_messages` with query `in:inbox` and `maxResults: 50`. Paginate with
`nextPageToken` until all messages are retrieved. Record: messageId, threadId, from,
subject, snippet, and labelIds for each message.

**Via Chrome browser:**
Navigate to `https://mail.google.com/mail/u/0/#inbox` and scroll through to inventory
all visible threads. Use `get_page_text` to read sender, subject, and snippet for each.

---

## Step 2: Classify Using the Eisenhower Matrix

Every email gets one quadrant:

- **Q1 (Urgent + Important):** Needs action today. Time-sensitive, high-stakes.
  Examples: meeting confirmations for today, urgent requests from contacts, deadlines.
- **Q2 (Important, Not Urgent):** Strategic, relationship, or growth emails.
  Examples: career conversations, mentorship threads, financial planning, health appointments.
- **Q3 (Urgent, Not Important):** Low-effort replies or delegatable items.
  Examples: RSVPs, quick confirmations, routine scheduling, verify-email links, invoice reviews.
- **Q4 (Not Important, Not Urgent):** Archive candidates.
  Examples: newsletters not matching exceptions, marketing, expired promos, automated
  notifications, social media alerts, subscription confirmations.

### Sacred Exceptions — NEVER Archive These

Regardless of quadrant classification, these categories stay in the inbox:

- **Elvis**: Anything from or about Elvis (elvis@elvis.ai, elvis@dlthub.com,
  ekk0809@gmail.com). Every email. No exceptions. Calendar invites, forwards, group
  threads — all of it.
- **Mashal**: Anything related to Mashal Gillani (mashalgillani22@gmail.com). Calendar
  accepts, shared docs, direct emails.
- **Clarisse**: Mentee. Anything from clarisse.cc@icloud.com or clarissec@uchicago.edu.
  Also Google Docs comment notifications from Clarisse Cheung.
- **Seeling**: Mentee's parent / paying client. Anything from seeling_cheung@yahoo.com.
- **Devtool**: Developer tools, AI tools, tech products, SaaS notifications.
- **Women in Tech**: PyLadies SF (pyladiessf@calendar.luma-mail.com), Anokhi Kastia
  (Lightning Talks from Women and Folks in Tech), Women+ in Open Source Day threads
  (Danica Fine coordination, sponsor outreach to Anaconda/CodeRabbit/etc.), Zoe Steinkamp
  threads.
- **AI Devtool Buyer**: Webinar content, follow-ups, or related communications.

**Tip:** The label `SS- done` (Label_1057069200304912536) marks emails already processed
in previous sessions. If an email has this label AND is still in the inbox, it was
intentionally kept — do not re-triage or archive it.

If an email matches an exception, bump it to at least Q2 even if it looks like Q4.

---

## Step 3: Apply Labels

Every inbox email should receive at least one label. An email can have multiple labels.
Use the **Life OS 3.0 label system** — a 2-level hierarchy based on M's 7 Pillars.
Always apply the most specific (child) label; the parent label provides grouping.

### marcellamay21@gmail.com — Life OS 3.0 Labels (7 Pillars × 7 Categories = 56 labels)

| Parent Label | Child Labels |
|---|---|
| **1-Health** | Fitness, Nutrition, Mental, Medical, Sleep, Reproductive, Recovery |
| **2-Systems** | Delegation, Errands, Digital, Admin, Home, Bills, Planning |
| **3-Networking** | Professional, Family, Friendships, Condomates, Acquaintances, Relationships, Groups |
| **4-Core** | Identity, Values, Self-Authorship, Boundaries, Character, Partnership, Joy |
| **5-Dreams** | Exploration, Vision, Future, Skills, Freedom, Rest, Curiosity |
| **6-Vocation** | Employment, Consultancy, Upskilling, Technical, Strategy, Teaching, Brand |
| **7-Finances** | Income, Budgeting, Investing, Debt, Protection, Partnership, Education |

**Labeling examples for marcellamay21:**
- BetterHelp email → `1-Health/Mental`
- Stifel statement → `7-Finances/Investing`
- Ali Rohde newsletter → `6-Vocation/Employment`
- Women in Tech meetup → `3-Networking/Groups`
- Elvis email → `3-Networking/Relationships` (or whatever pillar fits best)
- DocuSign for a lease → `2-Systems/Admin`
- Wells Fargo alert → `7-Finances/Budgeting` or `7-Finances/Protection`
- One Medical appointment → `1-Health/Medical`

### marcella@marcella.dev — Vocation Pillar Labels + Utility Labels

Since .dev is all Vocation, this account uses the full goal-level breakdown:

| Parent Label | Child Labels |
|---|---|
| **Employment** | Onboarding, Daily Workflow, Team Relationships, Performance, Goals, Feedback, Growth Path |
| **Consultancy** | Pipeline, Client Management, Proposals, Deliverables, Pricing, Contracts, Portfolio |
| **Upskilling** | Tableau, SQL, Data Engineering, Certifications, Online Courses, Practice Projects, Mentorship |
| **Technical** | Coding, Data Work, Tools, Debugging, Architecture, Documentation, Code Reviews |
| **Strategy** | GTM, Business Intelligence, Process Optimization, Frameworks, Research, Client Advisory, Case Studies |
| **Teaching** | Workshop Design, Content Creation, Delivery, Feedback, Scheduling, Marketing, Impact Tracking |
| **Brand** | LinkedIn Content, Thought Leadership, Speaking, Visibility, Narrative Control, Media, Reputation Tracking |

**Additional utility labels on marcella.dev (already exist):**
- `Networking` — General networking threads (Assad, Dori, etc.)
- `Events` — Event registrations, calendar invites, Luma confirmations
- `Action Required` — Anything needing M's direct action
- `Circle back` — Threads to revisit later
- `Saved for later` — Reference material
- `Newsletters` — Newsletter subscriptions
- `Reciepts` — Purchase receipts (note: typo is intentional, matches existing label)
- `Tools/Services` — SaaS and service notifications
- `job-search` and `js` — Job search related, with `js/Rejection` sublabel
- `SS- done` — Processed in a previous triage session
- `ATT 2026` — AT&T related
- `Wisdom` — Inspirational / reference content
- `Decide: Important/Not urgent` — Eisenhower Q2 items needing a decision
- `Delete: Nice to have` — Low-value items marked for eventual cleanup

**Labeling examples for marcella.dev:**
- LinkedIn notification → `Brand/LinkedIn Content`
- dltHub onboarding email → `Employment/Onboarding`
- Coursera receipt → `Upskilling/Online Courses`
- Client proposal thread → `Consultancy/Proposals`
- GitHub PR review → `Technical/Code Reviews`
- Conference speaker invite → `Brand/Speaking`
- Dori / Data Debug thread → `Networking` + `Brand/Speaking`
- Clarisse mentoring thread → `Consultancy/Client Management`
- Seeling payment thread → `Consultancy/Pricing`
- Assad/Elvis group thread → `Networking`
- PyLadies registration → `Events`
- Stripe verify email → `Action Required` + `Tools/Services`

### Labeling Rules

1. **Always use the most specific child label.** Don't just label `1-Health` — label `1-Health/Medical`.
2. **An email can have multiple labels.** A financial planning email about Elvis → `7-Finances/Planning` + `3-Networking/Relationships`.
3. **Action Required is additive.** Any email needing M's response gets the pillar label plus `Action Required`.
4. **When in doubt about which child label fits,** pick the closest match — the parent grouping will still provide correct categorization even if the child isn't perfect.

### Browser-Based Labeling Workflow (both accounts)

**Important:** Since Gmail MCP has no `gmail_modify_thread` tool, labeling on BOTH
accounts must use Chrome browser.

For batch labeling via Chrome browser, use this repeatable pattern:

1. Navigate to a Gmail search URL that filters the relevant emails
   (e.g., `https://mail.google.com/mail/u/0/#search/in:inbox+from:wells+fargo+OR+from:stifel`)
2. Click the "Select All" checkbox in the toolbar
3. Click the "Labels" button in the toolbar (icon looks like a tag)
4. Type the label name in the search box that appears (e.g., `7-Finances/Investing`)
5. Check the checkbox next to the label
6. Click "Apply"

Gmail's "/" separator creates the nested hierarchy automatically. When you type
`1-Health/Medical`, Gmail will show it nested under `1-Health`.

**Note:** URL-based search filtering is unreliable (see Known Limitations). If search
doesn't filter correctly, use MCP to identify message IDs first, then locate them
manually in the browser inbox.

---

## Step 4: Archive Q4 Emails

All Q4 (Not Important, Not Urgent) emails get archived — meaning they leave the inbox
but remain searchable. This is non-destructive.

**Important:** Double-check against the Sacred Exceptions list before archiving anything.
If it matches an exception, do not archive it.

**CRITICAL RULE:** Every email that gets archived MUST be labeled first. No archive
without a label. Label first, re-select, then archive.

**Via browser:** Select Q4 emails via coordinate-based clicks (not JS `.click()`), then
click the Archive toolbar button via `mcp__Claude_in_Chrome__computer` `left_click` at the
button's screen coordinates. See Chrome Browser Workarounds above — both JS `.click()` and
MouseEvent dispatch silently fail for archiving. Always screenshot to verify.
**Via MCP:** Not available. There is no `gmail_modify_thread` tool to remove the INBOX label.

---

## Step 5: Identify Emails Needing Responses

Scan remaining inbox emails for threads that need a reply from M. Skip these:

- Newsletters and marketing emails
- Automated notifications (shipping, account alerts, payment confirmations)
- Emails M has already replied to (check the thread for her response)
- Expired invitations or time-sensitive items that have passed
- Emails where no response is expected (FYI messages, CC'd threads)
- Calendar accept/decline notifications (no reply needed)
- Google Docs comment notifications (respond in the doc, not email)

Focus on:
- Direct questions to M
- Requests for action or information
- Relationship maintenance (congratulations, thank yous, check-ins)
- Professional opportunities requiring acknowledgment
- Threads where M's silence would be noticed
- Bounce-backs (flag for alternate contact info — don't just ignore them)

### Bounce-Back Handling

If a draft was sent and bounced (Delivery Status Notification / Failure), flag it
immediately. Record the failed email address and note that M needs an alternate contact
method for that person (LinkedIn, Slack, different email, etc.).

---

## Step 6: Write Lens-Reviewed Responses

### M's Process Preferences (confirmed Apr 2026)

- **Go one-by-one for Q3 items.** Don't batch-draft all replies at once. Process each
  email individually so M can review, edit, and approve before moving to the next.
- **Run ALL replies through:** Marcella voice + Promoted Employee frame + lens review + cut 1/3.
- **Networking deflect/stall drafts** get an additional filter: insider positioning.
  Position M as someone who's in the room, not trying to get in the room.
- **No dashes.** M's voice uses flowing sentences with "and"/"so"/"which" connectors.
- **No hedging.** No "just," "actually," "I think," or unnecessary qualifiers.
- **No escape ramps.** Don't offer the recipient a way to say no ("if you're too busy...").
- **No timeline commitments** unless M explicitly approves one. "Let's catch up at the
  next [event]" is better than "How about May?"
- **Short closers.** One-line declarative sign-offs. No multi-sentence wrap-ups.
- **Always include "Best, Marcella"** as the sign-off. Every single email.
- **NEVER offer M's time or availability.** No "Happy to find 15 minutes," no "How about
  Thursday?" Let the other person propose times. This is a hard rule with zero exceptions.
- **No colons.** Restructure with commas, periods, "which is," "meaning," or "and that means."
- **No forward slashes as punctuation.** No "and/or" or "X/Y" constructions. Pick one word,
  use "and," use "or," or restructure.

For each email needing a response, write a tight **2-3 sentence reply** using condensed
Lens Review principles:

1. **KYA (Know Your Audience):** Match the sender's tone and context. Professional for
   professional, warm for personal.
2. **Empowering Reframe:** Position M as proactive and in control. Never reactive or
   apologetic.
3. **Promise Audit:** Do NOT commit to anything M hasn't explicitly agreed to. No implied
   deliverables. No "I'll have it to you by Friday" unless M said that.
4. **Voss (Tactical Empathy):** Acknowledge the sender's intent or effort before responding.
5. **Pabrai (Asymmetric Thinking):** Maximize goodwill and relationship capital with
   minimal exposure or risk.
6. **Zero-Second Read:** The first sentence should make it immediately clear what M is
   saying yes, no, or next to.

### Voice Principles

Every response M sends should be:
- Direct, specific, confident — earned not inflated
- No "just," "actually," or unnecessary hedging
- No dashes — use flowing sentences with connectors (and, so, which, where)
- No implied promises or deliverables M didn't explicitly agree to
- Professional warmth without over-commitment
- Clean enough to be featured on the front page of a newspaper
- Numbers as proof when relevant (insider positioning)
- Short declarative closers

### Response Handling

- **Send directly** (or mark as "ready to send"): Simple acknowledgments, scheduling
  confirmations, routine replies where AI-generated is sufficient.
- **Save as draft** (and flag for M's review): Career decisions, financial matters, legal
  matters, personal relationship nuances, anything where M's judgment matters.

**Via MCP:** Use `gmail_create_draft` with `threadId` to create an in-thread draft.
**Via browser:** Click Reply on the thread, type the response, and leave it unsent (Gmail
auto-saves as a draft).

**Note:** There is no `gmail_delete_draft` tool. If M rejects a draft, discard it via
Chrome browser (open the draft, click the trash icon in the compose window).

---

## Step 7: Create Linear Tickets for Action Items

After labeling and identifying action items, create a Linear ticket for each email that
requires a concrete next step beyond just replying. Use `list_teams` and `list_projects`
to find the appropriate team and project.

**Action items that warrant a ticket:**
- Verify email / 2FA setup (Stripe, Link, etc.)
- Review and respond to follow-up questions (Ashley Conway use case, etc.)
- Schedule a meeting (Joe Hindle, Clarisse reschedule, etc.)
- Follow up on a bounce-back with alternate contact
- Invoice or payment action (Google Payments, Seeling)
- Event preparation or RSVP follow-through

Each ticket should include: the email subject, sender, one-line context, and the specific
action M needs to take.

---

## Step 8: Report Results

After completing the cleanup, provide a concise summary:

### Cleanup Results
- Emails archived (count)
- Emails labeled (count by label)
- Drafts created (count, with "ready to send" vs. "needs review" breakdown)
- Linear tickets created (count, with links)

### Needs M's Attention
- Drafts flagged for personal review (recipient + one-line context)
- Bounce-backs requiring alternate contact
- DocuSign signatures or forms requiring M's personal handling
- Time-sensitive items with deadlines

### Open Loops for Next Session
- Any emails that weren't fully processed
- Q3 items deferred for later
- Cross-account items (if only one account was cleaned)

Keep it scannable. M should be able to read the summary in under a minute and know
exactly what needs her hands on it.

---

## Recovery Mode Considerations

During surgery recovery (or any compressed-schedule period), apply these additional rules:

- Cross-reference email with calendar — events may be socially declined but not removed
  from the calendar.
- Err toward stall/deflect drafts rather than committing to meetings or deliverables.
- Short programs (≤2 weeks like Clay Wedge) don't need automation or heavy process.
- Keep draft count manageable — M has limited energy. Prioritize the 3-5 most important
  replies per session rather than drafting everything at once.

---

## Blockit Integration Note

Some threads (notably Dori Wilson / Data Debug) use Blockit (bot@blockit.com) as a CC'd
scheduling intermediary. Blockit auto-responds on M's behalf with availability checks.
When triaging these threads:

- The Blockit messages are automated — don't count them as M's replies.
- Check whether M herself has responded in the thread, not just Blockit.
- If M needs to respond, reply to the human sender directly (not Blockit).
