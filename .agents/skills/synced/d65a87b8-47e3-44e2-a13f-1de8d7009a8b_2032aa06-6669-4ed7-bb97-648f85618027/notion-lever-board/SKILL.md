---
name: notion-lever-board
description: >
  Create a Notion task board for any lever in the Life OS system. Use this skill whenever the user
  mentions creating a board, task board, Kanban, or tracker for one of their Life OS levers — things
  like "make a board for my Fitness lever," "create a task tracker for Side Project," "set up a board
  for Move," or "build out the Career lever like you did with Wedding." Also trigger when the user
  says "create a board like the Wedding one" or references the pattern of Lane/Priority/Owner task
  boards inside their Notion Life OS. Even casual mentions like "can you do a board for X" or
  "set up X the same way" should trigger this skill.
---

# Notion Lever Board

You are creating a task board (Notion database) for a lever in the user's Life OS system. This is a structured Kanban-style board that lives inside a lever page in their Notion workspace and helps them execute on that area of life.

## Context: The Life OS

The user's Notion workspace is organized around a **Seven Pillars Life Operating System**:

- **7 Pillars**: Health, Systems, Vocation, Finances, Core, Dreams, Networking
- **7 Dimensions per Pillar** = 49 total dimensions
- **7 Levers per Dimension** = 343 total levers

Each lever is a page inside the **Life OS 3.0** database (data source: `collection://5d07acc4-0254-4895-ac6b-6680cba0a5ea`). Lever pages have properties like Pillar, Dimension, Day, Status, etc.

When the user asks for a board, they want a **task database created as a child of the lever page**, pre-populated with actionable tasks.

## The Board Schema

Every lever board follows the same structure. This is non-negotiable — consistency across all levers is the point.

### Properties (always these 7, in this order)

| Property | Type | Details |
|----------|------|---------|
| **Task** | Title | The task name — action-oriented, clear, specific |
| **Status** | Status | Agile-style workflow tracking. Always use these stages: `Backlog` (default), `Up Next`, `In Progress`, `Blocked`, `Done`. This is the property you group by in Board view for a true Kanban. |
| **Lane** | Select | 4 categories that organize the work into meaningful swim lanes (custom per lever) |
| **Due** | Date | Leave empty on creation — the user fills these in once they have dates |
| **Priority** | Select | Always: `Must Do` (red), `Should Do` (orange), `Nice to Have` (green) |
| **Owner** | Select | Who's responsible — always includes `Marcella` plus 3-4 context-appropriate owners |
| **Notes** | Rich Text | Brief guidance, reminders, or context for each task |
| **Pillar** | Select | Which of the 7 Pillars this task touches. Always use these 7 options with these colors: `Health` (green), `Systems` (yellow), `Vocation` (orange), `Finances` (brown), `Core` (pink), `Dreams` (purple), `Networking` (red) |

### How Status works

Status uses Notion's native Status property type, which gives you a built-in Kanban board when you group by it. Notion's STATUS type has built-in group categories (To-do, In Progress, Complete) that power automatic behaviors like progress tracking. When you create a STATUS column, Notion generates default options — typically "Parking Lot," "To-do," "Doing," and "Done."

These map to a lightweight agile workflow:

- **Parking Lot** (To-do group) — captured but not yet scheduled. All tasks start here on creation.
- **To-do** (To-do group) — committed to for the current sprint/week. The user moves tasks here when they're ready.
- **Doing** (In Progress group) — actively being worked on right now.
- **Done** (Complete group) — completed.

The user can rename these in Notion or add more (like "Blocked" in the In Progress group) to match their preferred agile terminology. The important thing is the *groups* — they control Kanban column behavior.

This is different from Lane. Lane tells you *what kind of work* it is. Status tells you *where it is in the workflow*. A board can be grouped by either one depending on what view the user wants — thematic (Lane) or execution (Status).

### How to choose Lanes

Lanes are the heart of each board — they group the work into 4 meaningful categories specific to what the lever is about. Think of them as the major "fronts" or "theaters" of the work.

**Pattern from existing boards:**

- **Wedding**: The Day Itself, The Foundation, The Boundaries, The Logistics
- **Onboarding**: Setup & Access, People & Culture, Role & Deliverables, Admin & Compliance

Notice how the lanes aren't generic project management phases (don't use "Planning, Execution, Review, Done"). They're thematic categories that reflect how someone actually thinks about the work. When generating lanes:

1. Ask yourself: "If I were tackling this lever, what are the 4 distinct areas of effort?"
2. Make them mutually exclusive — every task should clearly belong to one lane
3. Give them evocative, specific names (not bland corporate labels)
4. Use distinct colors: blue, purple, orange, pink (in that order)

### How to choose Owners

Owners represent who's responsible for each task. Always include `Marcella` (blue) as the first option. Then add 3-4 other owners that make sense for the context. These might be specific people (like a partner, family member, manager) or role-based (like "Vendor," "Self-Directed," "HR/IT").

### How to generate Tasks

Pre-populate with **18-25 tasks** that cover the full scope of the lever. The tasks should feel like they came from someone who's actually done this before — practical, specific, and thoughtful.

**Distribution guidance:**
- ~10 Must Do (the non-negotiables)
- ~9 Should Do (important but more flexible)
- ~3 Nice to Have (stretch goals or quality-of-life improvements)

**Task quality checklist:**
- Action-oriented (starts with a verb or implies one)
- Specific enough to act on without further research
- Notes field includes the "why" or a helpful tip — not just restating the task
- Pillar assignment reflects which life area the task truly serves (a financial task during onboarding gets tagged Finances, not Vocation)
- Tasks should span all 4 lanes roughly evenly

## Step-by-Step Process

### 1. Find the lever page

Search Notion for the lever name. It should be a page inside the Life OS 3.0 database. Read its properties to understand which Pillar and Dimension it belongs to — this context informs your lane and task generation.

If the lever page doesn't exist yet, let the user know and ask if they want you to create it first.

### 2. Confirm the board details with the user

Before creating anything, briefly share your plan:
- The 4 Lanes you've chosen (with a one-line explanation of each)
- The Owner options you're proposing
- A note that you'll generate ~20 pre-populated tasks

Keep this tight — the user should be able to say "looks good" or "swap X for Y" without reading a wall of text.

### 3. Create the database

Use Notion's `create-database` tool with the lever page as the parent. The database should be named `[Lever Name] Tasks` (e.g., "Fitness Tasks," "Side Project Tasks").

**SQL schema template:**
```sql
CREATE TABLE (
  "Task" TITLE,
  "Status" STATUS,
  "Lane" SELECT('Lane1':blue, 'Lane2':purple, 'Lane3':orange, 'Lane4':pink),
  "Due" DATE,
  "Priority" SELECT('Must Do':red, 'Should Do':orange, 'Nice to Have':green),
  "Owner" SELECT('Marcella':blue, 'Owner2':purple, 'Owner3':gray, 'Owner4':green),
  "Notes" RICH_TEXT,
  "Pillar" SELECT('Health':green, 'Systems':yellow, 'Vocation':orange, 'Finances':brown, 'Core':pink, 'Dreams':purple, 'Networking':red)
)
```

After creating the database, update the Status property to have the correct options. Notion's STATUS type creates default options ("Not started", "In progress", "Done"), so use `update-data-source` to reconfigure them to: `Backlog`, `Up Next`, `In Progress`, `Blocked`, `Done`.

### 4. Populate with tasks

Create all tasks in a single batch using `create-pages` with the data source ID from the newly created database. Every task needs: Task, Status (set all to "Backlog"), Lane, Priority, Owner, Notes, and Pillar. Leave Due dates empty.

### 5. Present the result

Share the link to the new database and give a quick summary:
- Total task count
- Breakdown by lane
- Remind them they have two useful Board views available: group by **Status** for a classic agile Kanban (Backlog → Up Next → In Progress → Done), or group by **Lane** for a thematic view of the work. They can create both views in Notion.

## Examples of Good Lane Choices

These are meant to spark your thinking — don't copy them literally for different levers.

| Lever | Lanes |
|-------|-------|
| Fitness | Training, Nutrition, Recovery, Tracking |
| Side Project | Build, Launch, Community, Admin |
| Move / Relocation | The Search, The Transition, The Setup, The Handoffs |
| Therapy / Mental Health | Inner Work, Tools & Practices, Support System, Integration |
| Financial Planning | Income, Protection, Growth, Simplification |

## Things to Avoid

- Don't create generic "Phase 1, Phase 2, Phase 3" lanes — they should be thematic, not chronological
- Don't make tasks too vague ("Think about budget") — make them actionable ("Set monthly budget for X based on Y")
- Don't assign everything to Marcella — distribute ownership thoughtfully
- Don't tag every task with the lever's primary Pillar — tasks genuinely touch multiple pillars
- Don't add Due dates — the user assigns those based on their actual timeline
