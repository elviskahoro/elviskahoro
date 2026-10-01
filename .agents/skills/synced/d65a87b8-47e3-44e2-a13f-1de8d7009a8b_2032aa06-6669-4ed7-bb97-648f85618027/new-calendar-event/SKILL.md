---
name: new-calendar-event
description: Write a new calendar event to my Google Calendar. Use this skill whenever the user wants to
  create, schedule, or add any kind of calendar event — meetings, appointments, time blocks,
  reminders, deadlines, recurring events, or all-day events. Trigger when the user mentions
  scheduling, booking, blocking time, setting a reminder, adding something to their calendar,
  or describes any future event they want tracked. Even casual mentions like "put that on my
  calendar" or "remind me about X on Tuesday" should trigger this skill.
---

# New Calendar Event

You're creating a Google Calendar event for someone who treats their time as their most
valuable asset. Every event you create should reflect that — tight durations, smart defaults,
built-in breathing room. This person doesn't want a bloated calendar full of hour-long
meetings that could have been 20 minutes. Your job is to protect their time, not fill it.

## User's Timezone

**America/Los_Angeles (Pacific Time)**. All events should be created in this timezone unless
the user specifies otherwise. When the user says "3pm", they mean 3pm Pacific.

## Core Philosophy: Protect Their Time

Three rules guide every event you create:

1. **Shorter is better.** Default to the minimum viable duration. A 1:1 doesn't need 30
   minutes — 20 is plenty. A group meeting doesn't need 60 — 45 keeps people focused. If
   someone needs more time, they can extend. But time given away is gone forever.

2. **Build in margins.** Back-to-back meetings destroy focus and energy. When you can, use
   `gcal_list_events` to check what's already on the calendar around the proposed time. If
   the event would land right against another one, mention it — something like "Heads up,
   you have [other event] ending at 2pm, so this would be back-to-back. Want me to push it
   to 2:10 to give you breathing room?"

3. **Don't ask unnecessary questions.** If the user gives you enough to create the event,
   create it. The only things worth asking about are: time (if not given), and email
   addresses (if attendees are mentioned but you don't have their emails). Everything else —
   Meet links, reminders, duration — use the smart defaults below.

## Non-Negotiable: Every Meeting Has an Agenda

**EVERY meeting with another person MUST include an agenda in the description.** No exceptions.
A meeting without an agenda is a meeting without a purpose. If the user doesn't provide one,
draft a short agenda based on context.

Agenda format:
```
[Meeting Purpose: one line description]

Agenda:
1. [First topic]
2. [Second topic]
3. [Third topic]
4. Next steps

Looking forward to connecting!
```

Keep agendas to 3-5 items. Short, scannable, actionable. The agenda tells the attendee
exactly what to expect and signals that this person values their time.

For different meeting types:
- **Intro/exploratory calls**: Introductions, context gathering, goals discussion, explore fit/next steps
- **Client check-ins**: Progress review, blockers, upcoming priorities, action items
- **Informational interviews**: Introductions, their role/experience, your questions, advice/next steps
- **Internal syncs**: Updates, decisions needed, blockers, action items

## Title Format

Use the following formats for event titles:

- **External 1:1s**: "Name <> Name: Purpose"
  - Example: "Seeling <> Marcella: Intro Call"
  - Example: "Keith <> Marcella: Financial Review"
  - The other person's name goes first (they are the guest, you are the host)

- **Internal/team meetings**: "Team/Group Name: Purpose"
  - Example: "Sanhedrin Team: Weekly Sync"

- **Personal time blocks**: Clear, specific label
  - Example: "Deep Work: Proposal Draft"
  - Example: "Gym: Matteo Training Session"

- **Deadlines/reminders**: Action-oriented
  - Example: "DEADLINE: Submit Investor Deck"
  - Example: "Follow Up: Seeling re: Mentorship"

Never use vague titles like "Call" or "Meeting" or "Chat". Every title should tell you
what the meeting is about at a glance in a crowded calendar.

## The 3x3 Time Block Strategy

When the user needs to propose times to someone external, use the **3x3 grid**: offer times
across the 3 best booking days (Tuesday, Wednesday, Thursday) at 3 different time slots
that cover different scenarios:

| Slot | Time | Scenario |
|------|------|----------|
| Lunch | 12:00 PM PT | They have a flexible day |
| Late afternoon | 3:00 PM PT | They have a slow afternoon |
| End of day | 5:00 PM PT | They're booked solid until after work |

**Before proposing any times:**
1. Always run `gcal_find_my_free_time` to check the user's actual availability
2. Only propose times that are genuinely open
3. Offer on-the-hour times (12pm, 1pm, 2pm) not odd times (12:45pm, 2:15pm)
4. If a slot conflicts, find the nearest clean alternative
5. Present the times in a scannable format for the email:
   ```
   Tuesday 3/17: 12pm, 3pm, or 5pm PT
   Wednesday 3/18: 12pm, 3pm, or 4pm PT
   Thursday 3/19: 3pm or 5pm PT
   ```

**Why Tue/Wed/Thu:** Monday people are catching up. Friday people are winding down.
The middle of the week has the highest meeting acceptance rates.

**Why three time slots per day:** You're covering every possible schedule type the
other person might have. One of these nine slots will work for almost anyone.

## Date Calculation

Getting the date right matters. Here is how to calculate relative dates:

- **Today's date** is always provided in your system context. Use it as your anchor.
- **"Tomorrow"** = today's date + 1 day
- **"This [weekday]"** = the next occurrence of that weekday within the current week (Sun-Sat). If today IS that day, it means today.
- **"Next [weekday]"** = the occurrence of that weekday in the following week.
- **"This Friday"** when today is Wednesday March 5 = Friday March 7 (same week).
- **"Next Monday"** when today is Wednesday March 5 = Monday March 10 (the Monday of next week).

Always double-check your math by counting forward day by day from today. If you're unsure,
use a quick mental count: today is [day], +1 is [day], +2 is [day]... until you hit the target.

## Event Type Detection

Read the user's request and classify the event. This determines your defaults:

### 1:1 Meetings
Clues: one other person mentioned, "1:1", "call with [name]", "sync with [name]", "check in with"
- **Duration: 20 minutes.** This is intentional. Twenty minutes forces focus, respects both
  people's time, and almost always suffices. If someone explicitly asks for longer, honor it.
- **Google Meet**: Always add automatically
- **Reminders**: 10 minutes before
- **Description**: MUST include an agenda. Always.
- **Title**: Use "Name <> Name: Purpose" format

### Group Meetings
Clues: multiple people, "team meeting", "group call", "all-hands", "standup"
- **Duration: 45 minutes.** Not 60. Forty-five minutes is a full meeting with a 15-minute
  buffer built in before the next hour.
- **Google Meet**: Always add automatically
- **Reminders**: 10 minutes before
- **Description**: MUST include an agenda. Always.

### Personal Time Blocks
Clues: "block time", "deep work", "focus", "gym", "workout", "lunch", "meal prep", "journaling", "reading"
- **Duration**: 60 minutes (unless specified). This is *protected* time.
- **Google Meet**: No
- **Reminders**: 15 minutes before
- These blocks are just as important as meetings with other people. Treat them that way.

### Deadlines & Reminders
Clues: "deadline", "due", "remind me", "don't forget", "follow up"
- **Format**: All-day event for deadlines. 15-minute timed event for reminders.
- **Google Meet**: No
- **Reminders**: Deadlines get TWO reminders — 1 day before AND 1 hour before. Simple
  reminders get one at 30 minutes.
- **Description**: Spell out what action is needed. "Investor deck is due" → description
  should say "Submit/finalize the investor deck."

### Social & Personal Events
Clues: "dinner", "birthday", "party", "date night", "hangout", "brunch"
- **Duration**: 2 hours for meals/social, all-day for birthdays/holidays
- **Google Meet**: No (unless explicitly virtual)
- **Reminders**: 30 minutes before; 1 day before for birthdays
- **Location**: Ask if not provided — location matters for social events

### Recurring Events
Clues: "every week", "daily", "monthly", "recurring", "every Monday"
- Apply the appropriate type defaults above
- Set recurrence rule: RRULE:FREQ=WEEKLY;BYDAY=MO, RRULE:FREQ=DAILY, etc.

## Creating the Event

Use `gcal_create_event` with `calendarId: "primary"`.

### Always Include
- **summary**: Use the title format rules above. "Name <> Name: Purpose" for external 1:1s.
- **start/end**: Use `timeZone: "America/Los_Angeles"` in the start and end objects. This
  lets Google handle DST automatically and is more reliable than hardcoding UTC offsets.
  Format: `"dateTime": "2026-03-10T10:00:00", "timeZone": "America/Los_Angeles"`
- **reminders**: Always override defaults (`useDefault: false`) and set type-appropriate
  reminders using `"method": "popup"`.
- **description**: MUST include an agenda for any meeting with another person.

### Add When Appropriate
- **conferenceData**: For ANY meeting with other people, add Google Meet:
  ```json
  "conferenceData": {
    "createRequest": {
      "conferenceSolutionKey": {"type": "hangoutsMeet"},
      "requestId": "unique-string-here"
    }
  }
  ```
  Use a descriptive requestId like "seeling-mentorship-intro-20260317".
- **attendees**: Only if you have real email addresses. Never fabricate or guess emails. If
  the user mentions a name without an email, create the event and then ask for the email so
  you can add them.
- **location**: For in-person events only. Virtual meetings have the Meet link.
- **recurrence**: Array of RRULE strings for repeating events.

## After Creating

Confirm briefly — title, date/time in human format, duration, agenda summary, and the Meet
link if there is one. That's it. Something like:

> "Booked: Seeling <> Marcella: Intro Call — Tuesday, March 17 at 12:00 PM PT (20 min).
> Agenda: Introductions, career goals discussion, explore fit, next steps.
> Meet link: [link]. You'll get a reminder 10 minutes before."

If you noticed a back-to-back conflict, mention it. If you need an email to add an attendee,
ask for it now. Otherwise, done.
