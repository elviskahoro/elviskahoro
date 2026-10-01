---
name: daily-linkedin-post-manual
description: Research one interesting development from the AI and data engineering world, draft a LinkedIn post in M's devtools-insider voice, run it through full review, present the publish-ready draft for M's explicit yes, then post to LinkedIn and add the follow-up comment.
---

# Daily LinkedIn Post — Manual Task

Trigger phrases: "let's do today's LinkedIn post," "run the daily LinkedIn post," "draft a LinkedIn post," "find a data engineering story for LinkedIn," any similar variation.

Companion files in this folder describe the specific rules. Read them when the relevant step calls for them. Always check `lessons-learned.md` if anything goes sideways during the browser-automation steps.

## Step 1 — Research

Read `research-rules.md` for the source rules, blocked companies list, and thematic variety guardrails.

Read `/Users/marcella/Library/Application Support/Claude/local-agent-mode-sessions/.../memory/linkedin_posts_used.md` and skip any story already used in a prior run in this same week. Pull the last 5 posts to understand the thematic frames recently used so the new post rotates off them.

Pick one story from a company's own blog, press release, or official announcement page published within the last 10 days. No third-party news articles, no TechCrunch summaries, no secondhand reports.

Surface the candidate story to M before drafting if there is any doubt about fit, recency, or thematic rotation. M's explicit yes is required before drafting begins.

## Step 2 — Draft

Read `post-template.md` for the devtools-insider voice format (current default) and the legacy Proven Post Template (fallback for stories that fit better with the six-beat structure).

Read `voice-rules.md` for the non-negotiable voice rules — no dashes, no colons, no forward slashes as punctuation, alliteration thread tied to the story's core noun, pain-point vocabulary, no duplicate numbers across paragraphs.

Build the draft. Map every factual claim back to a verbatim or near-verbatim line in the source before presenting the draft. The source-mapping table catches overstatements like "every agent ships [these spans]" or "most enterprise X" where the source only names a finite set.

## Step 3 — Marcella Voice Check

Pass the draft through every rule in `voice-rules.md`. Fix any dashes, colons, slashes, hedging, filler, duplicate numbers, or vague intensifiers ("real," "bad," "right," "good"). Confirm the consonant thread runs through every paragraph. Confirm the closer names an engineer pain, not a generic phrase.

## Step 4 — Lens Review

Read `lens-review.md` and run the draft through every lens in order. Apply fixes inline.

## Step 5 — Present the publish-ready draft to M

Show M the final draft text, the follow-up comment text, the source URL, and a one-line note on what makes the story worth posting. Wait for explicit yes before proceeding to Step 6.

"Bump," "looks good," and similar non-affirmative replies do not count as yes. M's clear affirmative ("ok post it," "yes ship it," "go") is required.

## Step 6 — Post to LinkedIn

Use the Claude in Chrome MCP tools (`mcp__Claude_in_Chrome__*`). If the extension is not connected, save the draft to the outputs folder as a markdown file and tell M to either reconnect the extension or post manually.

1. Navigate to https://www.linkedin.com/feed/
2. Click the "Start a post" button (prefer coordinate click over JS button click — see `lessons-learned.md`)
3. Type the full post text including link and hashtags
4. Confirm the editor content matches the draft via `editor.innerText` length check
5. Click Post
6. Wait for the "Post successful" snackbar before navigating away

## Step 7 — Extract the URN

Navigate to `https://www.linkedin.com/in/depunzio/recent-activity/all/` and extract the newest activity URN via regex on `document.body.innerHTML`. Confirm the URN is newer than the most recent URN in `linkedin_posts_used.md`. See `lessons-learned.md` for the URN-extraction trap (never trust the first URN regex on the feed page).

## Step 8 — Follow-up comment

Draft a one-sentence factual comment linking to a related official post from the same company for readers who want to learn more. Format: one sentence of hand-off context, then the URL on its own line. No hedging, no hashtags in the comment.

From the recent-activity page (where the post displays inline), direct coordinate click on the visible "Add a comment..." pill to focus the input. Use standard `type` action for the comment. Click the blue Comment button. Confirm the "Author • now" badge appears.

## Step 9 — Log and report

Append the published post to `/Users/marcella/Library/Application Support/Claude/local-agent-mode-sessions/.../memory/linkedin_posts_used.md` under the current week's section. Include: story name, source URL, posted date, post URL, activity URN, full post text, follow-up comment text, and a hypothesis-for-performance note that captures the thematic frame and closer pattern for future thematic-variety checks.

Then confirm what was posted with the full post text and a one-line note on the story sourced.

## Failure recovery

- Chrome extension not connected → save draft as markdown to outputs folder, tell M.
- Edit modal appears mid-flow → press Escape, take a fresh screenshot, re-orient before sending more input. Never `type` into a modal whose origin isn't traceable to the automation's own clicks.
- Wrong URN extracted → re-extract from `/in/depunzio/recent-activity/all/`, not from the feed page.
- Composer button coordinates shifted from the last run → re-screenshot at every viewport. LinkedIn reflows between sessions.

Full recovery patterns live in `lessons-learned.md`.
