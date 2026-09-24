# Heath's OmniFocus conventions

Snapshot from a review of the database on 2026-09-24 (roughly 230 remaining and 400 recently completed tasks). Treat it as a guide to **how** things are organized. **Always re-fetch live projects and tags** before placing tasks, because names and IDs change.

## Contents
1. Folder and project layout
2. How tags are actually used
3. Date conventions observed
4. Good tasks vs. over-granular tasks (real examples)

---

## 1. Folder and project layout

| Folder | What goes there | Notable active projects |
|---|---|---|
| **Work — Figma** | Current job (started at Figma, Sept 2026) | `Onboarding` (parallel project: setup, benefits questions, people to meet) |
| **Personal** | Home, family, money, health, hobbies | `Personal Admin` (single-action catch-all), `Finance` (single-action: bills, claims), `2026 Financial Plan` (big project with action groups by phase), `Home`, `Car`, `Health`, `Travel` (SAL), `Cleaning` (SAL), `Recurring Reminders` (SAL), `Fox`, `Ruby`, `Parenting` (SAL), `Moving`, `Get Married`, `Ski Season`, specific outcome projects like "Get to the bottom of Dignity Health birth bill" |
| **Professional** | Career beyond the current job | `Career` (SAL), `Portfolio`, `Curatext`, `GitHub Profile README` |
| **Someday/Maybe…** | Not committed; every project here is on hold | `Ideas` (general someday ideas), `Watch/Read List`, `Restaurants to Try`, `Music`. Use these for anything Heath frames as "someday" or "maybe". |
| *(no folder)* | Cross-cutting | `GTD System` (daily and weekly review routines, **plus OmniFocus/GTD system upkeep** such as tag cleanup and perspective changes; don't add unrelated work here), `Learn/Research` (articles and papers to read) |
| **Work** *(dropped)* | Old Meta job | **Never file here.** Its tag groups (`Projects/*`, `Teams/*`) are also stale. |

Patterns:
- **Single-action lists** (SAL) collect unrelated one-offs in an area. Use them when an item doesn't belong to a specific outcome.
- **Outcome projects** are named as the result ("Get to the bottom of…", "Create posture routine…", "Get Married"). When a session produces a real multi-step outcome, propose a project named like this.
- **Action groups** inside big projects organize by phase or trigger: "Before Figma start", "After first Figma paycheck", "November / December review", "2027 setup". These are Heath's own structure. A new task that clearly belongs in one of them can go there (`parentTaskId`).
- **Subtasks, as Heath actually uses them:** small outcomes with 2–5 discrete children ("Book travel" → hotel, rental car; "Figure out how to use dell monitor as a KVM switch" → buy cables, buy receiver, configure DDPM; "Set up laptop" → installs), conditional follow-ups ("Revisit OpenAI … opportunity" → check if the role is still posted, then if open send one follow-up), and phase groups in big projects. One level deep. The bad examples in section 4 (procedure steps, values, three-level nesting in the Cultivar project) are what to avoid.
- **Sequential projects** are used where the order really matters (the bill dispute, Get Married).
- The **Inbox** is for quick unsorted capture. It's a fine landing spot when Heath chooses "file it later".
- Work at Figma other than onboarding currently has **no project**. Work items from sessions will often need a new project in `Work — Figma`, so ask.
- Claude Code / dev-tooling work (skills, MCP servers, personal repos) is placed **case by case, so always ask**. Precedent: "Fix omnifocus-mcp filter and date bugs" (created 2026-09-24) lives in Professional, next to the other public GitHub work.

## 2. How tags are actually used

About half of tasks have **no tags at all**. Tags are for filtering, not labeling. Frequency among completed tasks: GTD 111, admin 62, Mom 22, calls 21, cats 20, finance 18, med~1hr 12, personal 9, clean 9, travel 6, car 4, Pharmacy 3, home 3.

| Tag | Use it for |
|---|---|
| `claude` | **Every task this skill creates** |
| `waiting` *(on hold)* | Blocked on an external event or person. The tag alone is enough: Heath checks Waiting For every few days, so don't add a defer or planned date for an expected reply. The task is named as Heath's own action, with the blocker in the note. Examples: "Review itemized bill" (waiting for the bill to arrive), "Xfer AMZN stock to Hazel" (note: "Call Frec"). Shows up in the **Waiting For** perspective. |
| `People/<Name>` | Agenda items to raise with that person: "Questions for Erica" → `Erica`. Family tags `Mom`, `Dad`, `Fox`, `Ruby`, `Bobbie`. **Only for ongoing relationships.** One-off contacts never get a tag; name them in the task instead. For a new ongoing relationship with no tag, propose one (under `People`) in the preview. |
| `calls` | Phone calls ("Call Trupanion to change address", "Call Mom") |
| `email` | Email-only actions |
| `Errands` → `Supermarket`, `Hardware Store`, `Department Store`, `Pharmacy` | Out-of-house trips ("Pick up rx from CVS" → `Pharmacy`) |
| `Mac` | Tasks that need the computer, used for setup/publish-type work ("Create public GitHub repo", "Order Certified Marriage Certificate"). Optional, since most Claude-session tasks are computer tasks anyway. |
| `finance`, `taxes`, `benefits`, `subscriptions`, `health`, `career`, `car`, `cats`, `travel`, `home`, `bike` | Area tags. Use one when it adds filtering value; `finance` is common even inside finance projects. |
| `writing`, `review` | Drafting and review work. |
| `short~15min`, `med~1hr`, `long~4+hrs` | Time context. Rarely used; prefer `estimatedMinutes`. |
| `GTD`, `admin` | Heath's review routines. **Don't use.** |
| `🔴P1`/`🟡P2`/`🟢P3`, `Projects/*`, `Teams/*` | Unused or stale. **Don't use** unless asked. |
| `blocked`, `delegated` *(on hold)* | Exist but are unused. Prefer `waiting`. |

**Casing convention (Heath, 2026-09-24):** tags are lowercase unless they name a person or other proper noun (a specific place, company, or product: `Erica`, `Figma`, `Mac`). Many older tags are capitalized anyway (`Errands`, `Pharmacy`, `Computer`, `Job Search`). Use them as they are; just don't propose new ones in that style.

## 3. Date conventions observed

- Defer dates are almost always **start of day** (00:00 local). Planned dates are usually **09:00 local**.
- **Bills and deadline chores:** defer a few days before the due date ("Pay AMEX" defer 10/16, due 10/19; "Do expenses" defer 9/27, due 9/30).
- **Future-phase items** get a defer date for when they become relevant plus a planned date for the intended work day ("Check updated Frec YTD realized tax losses" defer 11/20, planned 11/25).
- **Due dates are for hard deadlines only** (GTD; Heath confirmed 2026-09-24). 74 of 400 completed tasks had one, nearly all real deadlines (payments, claims, filings). Soft "should do by" dates go in **planned**, with the reason in the note.
- **Default times:** defer 00:00, planned 09:00, due 17:00 unless there's a specific time.
- **Flags** mark things to do in the next few days (bills, pickups, onboarding info right before the start date). About a quarter of tasks are flagged, but default to unflagged.
- Timezone: America/Los_Angeles. A bare `YYYY-MM-DD` gets the default times above; use `scripts/of_date.sh` for any other time.

## 4. Good tasks vs. over-granular tasks (real examples)

**Good: one sitting, one context, detail in the note**
- "Call insurance to verify claim processing". The note lists five specific questions.
- "Pull EOBs from insurance portal". The note says which EOBs, which dates of service, and what to compare.
- "Set Figma traditional 401(k) contribution". The note holds the remaining-limit math.
- "Enroll in Figma ESPP at 15% for the partial 2026 period". The note holds the conditions.
- "If still open, send Laura one concise follow-up in the existing email thread". The note has the message outline.
- "Make remaining 2026 HSA contribution directly to Fidelity". Defer, planned, and due are all set for real reasons; the note has amounts for each scenario.

**Over-granular: what this skill must not produce**
- Fork leak check split into "Wipe both fork stanchions…", "Compress the fork 10–20 times", "Take a short test ride", "Inspect the stanchions…", "Keep lubricant away from the front brake rotor", "If only a faint, even oil film returns…". → This should have been **one task**, "Do Fox 36 fork leak check", with the procedure in the note.
- Roth rebalance split into "VTI: 40%", "VEA: 40%", "VWO: 20%", "Bonds: 0%", "Use", "existing SPAXX cash", "approximately $3,976 from AGG sale", "Target Roth allocation". → These are **values and fragments, not actions**. The right result is one or two tasks ("Sell AGG and rebalance Roth IRA to 40/40/20 VTI/VEA/VWO") with the targets in the note.
- 401(k) percentages as tasks ("Ss Tot Stk Mkt Idx I: 44.4%", "Ss US Bond Index X: 20.3%"). → These belong in the note of "Reallocate Meta 401(k) to target mix".
- GitHub Profile README broken into 15 tasks, including separate "Add portfolio link", "Add LinkedIn link", "Add AI Doc Evals Playbook link", "Review for brevity", and "Remove visual clutter". → About 4 tasks: "Draft profile README (positioning, focus areas, what to look at, links)", "Edit README for brevity and clutter", "Publish README and pin portfolio + playbook repos", "Review pinned repos for hiring-manager signal".

- Cultivar Contribution nested three levels deep ("Phase 3 — Self-eval dogfood" → "Skill dogfood (…)" → "Ask maintainer…"), with status notes in the task names ("[DRAFTS READY, UNBLOCKED]"). → Should have been flat tasks in the project, with status in the project note.

**Too vague: lift to the next physical action**
- "Deal with cobra" → "Call COBRA administrator to confirm election deadline"
- "Figure out $500/mo childcare benefit" → "Read Figma childcare benefit policy and note how to claim"
- "Is there a second brain solution?" → "Ask Alyssa what note-taking/second-brain tool the team uses" (tag `Alyssa`)
