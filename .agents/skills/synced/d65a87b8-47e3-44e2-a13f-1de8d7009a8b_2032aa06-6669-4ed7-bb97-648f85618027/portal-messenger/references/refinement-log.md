# Portal Messenger — Refinement Log

Each entry captures what was learned from a real use of this skill, so the skill gets sharper over time.

---

## 2026-03-23 — LifeStance Health (Northern California)

**Portal:** LifeStance Health → AdvancedMD Patient Portal
**Task:** Send pre-conception planning message to psychiatrist (Dr. Ashley Hoeck-Anderson, DO)
**Message source:** Notion — "Pregnancy Preparation — Advocacy Materials"

**What was learned:**
- LifeStance patient portal requires a state selector before showing portal links. California → "Central/North California" is the correct path for M.
- The portal auto-prepends a greeting line (e.g., "Hi Dr. Ashley Hoeck-Anderson,") before the message body — no need to include a greeting in the typed message if the portal adds one.
- The compose page is accessed via "Ask a Question" button from the Inbox.
- Physician and Patient dropdowns are pre-populated — no manual selection needed.
- The subject defaults to "Ask Physician/Provider Directly" which is appropriate for most direct messages.
- After sending, a green confirmation banner appears: "Your message has been sent."
- Tab IDs can expire between actions — always re-check with `tabs_context_mcp` if a navigation fails.

**Changes made:**
- Saved portal navigation path to memory (`reference_lifestance_portal.md`)
- Saved provider and medication context to memory (`user_health_psychiatry.md`)
- These learnings informed the "Handling common portal patterns" section of the skill.

---

## 2026-03-23 — Amazon One Medical (PCP: Jessica Shahpar, FNP)

**Portal:** Amazon One Medical (app.onemedical.com → health.amazon.com auth)
**Task:** Message PCP about Nourish referral not accepting insurance + request alternative nutrition support
**Message mode:** Mode B — drafted by skill based on user's situation
**Drafting context:** User tried to sign up for Nourish nutrition coaching (referred by PCP), insurance wasn't accepted, needed to loop back to PCP for an alternative

**What was learned:**
- One Medical uses Amazon authentication, which includes a phone verification step. This is a multi-step auth handoff — tell the user upfront they may need their phone for a verification code.
- The Gmail MCP connector was connected to M's professional email (marcella@marcella.dev), not personal (marcellamay21@gmail.com). Had to use browser to access personal Gmail instead. **Skill should note:** when looking for referral emails, check which email account the connector uses vs. which account the referral went to.
- The Nourish referral email was found by searching "nourish" in personal Gmail via browser — the email contained a pre-filled sign-up link from the provider.
- One Medical's compose form is straightforward: Subject + message body + recipient dropdown. Recipient must be manually changed from "Admin Team" (default) to the provider.
- One Medical shows sent messages inline on the same Messages page — no separate "Sent" folder to verify. Confirmation is seeing the message appear with a "Reply to message" field below it.
- The draft was written without running lens-review because the user wanted to move quickly. **Skill should note:** offer lens review but don't force it when the user's momentum is clear.
- This was a real-world Mode B test: user described the situation, skill drafted the message, navigated the portal, entered it, and sent on user confirmation. The full cycle worked end-to-end.
- Account creation (for Nourish) is a prohibited action — skill correctly handed that off to the user.

**Changes made:**
- Saved One Medical portal navigation to memory (`reference_onemedical_portal.md`)
- Updated MEMORY.md index
- Identified skill gap: need to add guidance about email account mismatch when searching for referral links
- Identified skill gap: need to add guidance about multi-step authentication (Amazon-style verification codes)
