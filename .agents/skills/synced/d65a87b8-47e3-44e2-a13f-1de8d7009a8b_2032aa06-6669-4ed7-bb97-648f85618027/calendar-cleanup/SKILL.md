---
name: calendar-cleanup
description: >
  Audit and clean up M's Google Calendar across both accounts — find conflicts, remove
  declined events, and prep tomorrow's schedule. Trigger when the user says "clean my
  calendar," "calendar cleanup," "audit my calendar," "check my calendar," "what's on my
  calendar tomorrow," "any conflicts," "calendar check," "prep tomorrow," "day prep,"
  "nightly cleanup," "8pm cleanup," or any variation of wanting their calendar audited,
  conflicts resolved, or next day prepped. Also trigger when the user says "my calendar
  is a mess," "am I double-booked," "do I have anything conflicting," or casually mentions
  needing to review what's coming up. This skill handles the full pipeline: cross-calendar
  conflict detection, email cross-referencing for declined events, tomorrow's audit, and
  auto-resolution with a clean summary. Trigger proactively and liberally — if the user
  mentions their calendar at all, this is the skill.
---

# Calendar Cleanup

You're running M's calendar cleanup — a system that takes two Google Calendars, treats
them as one unified schedule, finds every problem, fixes what it can, and reports what
it did. The philosophy is simple: act first, report after. M doesn't want to approve
every little move. She wants to open her calendar and see it clean.

## The Two Calendars

M runs two Google Calendars as a single unified schedule. No event on either calendar
can overlap with any event on the other. They are:

- **Official:** `marcella@marcella.dev`
- **Personal:** `marcellamay21@gmail.com`

When creating or modifying events on either calendar, always include both attendees:
`marcellamay21@gmail.com` and `sf.bay.household@gmail.com`.

**Timezone:** `America/Los_Angeles` (Pacific Time), always.

**Gmail for email cross-referencing:** `marcellamay21@gmail.com` (use `gmail_search_messages`
from the Gmail MCP).

## What This Skill Does

Every cleanup runs three passes, in order. However, if the user's request is specifically
about tomorrow (e.g., "what does tomorrow look like"), prioritize Pass 3 first and run
Passes 1-2 only on tomorrow's events rather than the full week. Match the scope to the ask.

### Pass 1: Cross-Calendar Conflict Detection

Pull all events from both calendars for the audit window (default: today through end of
next week, but expand if the user asks for a broader range). Then find every case where
events overlap across or within calendars.

Use `gcal_list_events` on both calendar IDs (`marcella@marcella.dev` and
`marcellamay21@gmail.com`) with the same time range. Walk through every event pair and
check for time overlaps. An overlap means one event's start falls between
another event's start and end, or one event fully contains another.

For each conflict found, classify both events:

**Immovable events** (do not touch these):
- External commitments with other people (meetings, calls, appointments)
- Medical/dental/health appointments
- Physical activities with fixed durations (hikes, gym with trainer, league sports)
- Travel or transit blocks (distance = time, non-negotiable)
- Events with a physical location that implies fixed logistics
- Anything where shortening or moving would violate common sense (a 5-hour ranch visit
  is a 5-hour ranch visit — you can't compress it to 2 hours)

**Movable events** (these can be adjusted):
- Recurring personal blocks (work blocks, review sessions, check-ins)
- Prep reminders and wind-up/wind-down blocks
- Solo tasks without external dependencies
- Pillar review blocks and admin time

**Resolution rules:**
- Immovable vs. movable → delete or move the movable event for that day
- Movable vs. movable → move the less important one (pillar blocks < work blocks < admin)
- Immovable vs. immovable → DO NOT auto-resolve. Flag for M with both events and times.
- Duplicates (same event on both calendars) → delete the one on the less appropriate calendar

When moving an event, find the nearest open slot that doesn't create a new conflict.
Prefer moving later in the day rather than earlier. Preserve the event's duration.

When deleting a recurring event instance for a conflict, use the instance ID (with the
date suffix like `_20260324T160000Z`) so you only affect that one occurrence, not the
whole series. This is critical — never delete a series when you mean to skip one day.

To delete an event, use `gcal_delete_event` with the correct `calendarId` and `eventId`.
To update an event, use `gcal_update_event`. To inspect an event before acting, use
`gcal_get_event`.

### Pass 2: Email Cross-Reference

This matters more than people think. M sometimes declines events informally — she'll
email the organizer saying she can't make it, but the event stays on her calendar. The
calendar alone doesn't tell the full story.

For each event in the audit window that involves other people (has attendees beyond M's
own accounts), search Gmail for recent messages about that event. Use `gmail_search_messages`
with the event name, organizer name, or key attendees as search terms.

Look for:
- M sending a message saying she can't attend, won't make it, needs to cancel, or is declining
- The organizer sending a cancellation
- A thread where the event was rescheduled to a different time

If you find evidence that M has already communicated she's not going, **delete the event
from the calendar**. If you find it was rescheduled, update the time. If you find a
cancellation from the organizer, delete it.

This pass is especially important during recovery periods or when M has been managing
her schedule informally via email rather than through calendar RSVPs.

### Pass 3: Tomorrow's Audit

Regardless of the broader audit window, always do a focused pass on tomorrow's schedule.
This is the most actionable output — M is about to live this day.

Pull tomorrow's events from both calendars and present them as one merged, chronological
timeline. For each event, show:
- Time (start – end)
- Title
- Which calendar it's on
- Location if any
- Whether it conflicts with anything

Check for:
- Back-to-back events with no buffer (flag but don't auto-fix — M may want it tight)
- Events that require travel between locations without enough transit time
- Events that run past 9:30 PM (M's wind-down boundary)
- Unrealistic density (too many things stacked together for a recovery day)

## How to Fix Things

This skill operates on a **fix first, report after** philosophy. Don't ask permission for
each change. Make the smart call and tell M what you did.

**Actions you should take without asking:**
- Delete duplicate events (same title/time on both calendars)
- Delete events M has declined via email
- Delete cancelled events
- Move movable events that conflict with immovable ones
- Delete movable event instances when they conflict with immovable events and there's no
  good alternative slot

**Actions that need M's input:**
- Two immovable events conflicting (present both, ask which to keep)
- Events where you're not sure if they've been declined (show the email evidence and ask)
- Deleting an entire recurring series (as opposed to one instance)

## The Cleanup Report

After all three passes are complete and fixes are applied, present a clean summary. This
is the only thing M needs to read — make it worth her time.

Structure:

**Conflicts Found & Resolved (X)**
For each: what conflicted, what you did about it, and why.

**Events Removed (X)**
For each: what was removed and the evidence (email decline, cancellation, duplicate).

**Tomorrow at a Glance**
The merged chronological timeline of tomorrow's final, cleaned-up schedule.

**Needs Your Call (X)** *(only if there are unresolvable items)*
For each: the two conflicting events, times, and what you need M to decide.

Keep the report scannable. M should be able to read it in under 2 minutes and know her
calendar is clean.

## Notion Knowledge Base

M maintains a growing repository of calendar common sense rules in Notion:
- **Database:** "Calendar Intelligence — Common Sense Rules"
- **Database ID:** `b332927dafc14a7ca5d0063f7887b74b`

Before making fixes, check this database for any rules that apply to the events you're
handling. After the cleanup, if you discovered a new pattern worth remembering (e.g.,
"M always declines Thursday evening events during recovery" or "Admin Power Hour should
never be moved"), offer to add it to the knowledge base.

## Recurring Event Safety

When modifying recurring events, always use instance-level operations:
- To skip one occurrence: delete using the instance ID (e.g., `eventId_20260505T233000Z`)
- To move one occurrence: update the instance, not the series
- To change the whole series going forward: use the recurring event ID (parent) with
  appropriate update scope

Never accidentally delete an entire series when fixing one day's conflict. If you're
unsure which ID to use, fetch the event first with `gcal_get_event` to see whether it
has a `recurringEventId` field.

## Recovery Mode Awareness

Check memory for whether M is in recovery mode. If she is, apply these additional filters:
- Flag any day with more than ~2 hours of work blocks as potentially too heavy
- Be more aggressive about removing optional events
- Cross-reference email more carefully (M declines more informally during recovery)
- Don't add new events or suggest rescheduling into recovery windows

Even if M didn't select this as a core feature, it affects how every other pass works
when active, so stay aware of it.
