---
name: taskify
description: Turn the leftover action items from the current Claude Code session into GTD-style next actions in Heath's OmniFocus database, via the OmniFocus MCP server, with the right project, tags, and defer/planned/due dates. Use whenever the user says /taskify, "taskify this", "add the follow-ups to OmniFocus", "put the remaining items in OF", "capture next steps", "make tasks for what's left", or is wrapping up a session that has unfinished to-dos, open questions, or things only they can do (calls, emails, purchases, approvals, manual verification). Also use when the user asks to log waiting-for items or follow-ups from a session into OmniFocus, even if they don't say "task".
---

# Taskify

Capture what's left over from this session as a small set of well-formed GTD next actions in OmniFocus. Get each task's project, tags, and dates right so Heath can trust his system without re-processing the list.

The hard part is **judgment about what counts as a task**, not the API calls. Earlier attempts at this failed by producing too many tasks that were too granular: procedure steps, config values, and facts turned into to-dos. Most of this skill is about avoiding that.

## Workflow

1. **Harvest** candidate items from the conversation.
2. **Scan OmniFocus** for tasks that already cover each item, and load live projects and tags.
3. **Shape** what's left into GTD next actions. Merge, lift, or drop each one.
4. **Place** each new action in a project with tags and dates. Note every placement you're unsure of.
5. **Preview** the plan (new tasks *and* edits to existing tasks) and ask your questions in a single round.
6. **Write** the approved changes, then **sync** once.
7. **Report** what changed.

If `/taskify` came with arguments (e.g. `/taskify just the deploy follow-ups`), treat them as a scope filter or extra instructions for step 1. If the arguments include `--dry-run` or "preview only", stop after step 5 and write nothing. In a dry run, show the questions with your recommended answers instead of calling AskUserQuestion.

---

## 1. Harvest

Read the whole session and collect:

- Explicit next steps, TODOs, and "you'll need to…" statements from either side
- Things only Heath can do: phone calls, emails, purchases, approvals, logging into something, physical-world tasks, decisions
- Things started but not finished, or finished but not verified (e.g. "deploy and confirm it works in prod")
- Things waiting on someone or something else: a reply, a review, a shipment, a date
- Decisions Heath deferred ("let's decide on X later")
- Someday/maybe ideas ("someday it'd be cool to…"). Capture them, but as someday items (see step 4), never as next actions.

Leave out:

- Anything already done in this session
- Pure information such as numbers, settings, how-to steps, URLs, addresses, and passwords-on-a-card. These belong in the note of the task they support, not in tasks of their own. If a related task exists (e.g. "On-site onboarding info"), propose appending it there. If nothing related exists, list it under "Left out" rather than inventing a task to hold it.
- Plans Heath reversed during the session ("actually never mind, I'll ask Erica first"). Capture only the final version.
- Anything you, Claude, could finish right now in this session. List these separately in the preview under "I can do these now instead." Parking work in OmniFocus that could simply be done now is a waste.

## 2. Scan OmniFocus first

Heath often captures things himself before a session ends, and many sessions continue work that's already in his system. The first job is to update what exists rather than add near-duplicates next to it.

Always go through the OmniFocus MCP server (`mcp__omnifocus__*`). Load the tool schemas with ToolSearch first if they're deferred. Never use AppleScript, `osascript`, or URL schemes as a workaround.

**Load live context (fresh every run, since names and IDs change):**
- `list_projects` with `status: "active"` gives project names, IDs, folders, and whether each is a single-action list. If there's a someday item, also run `list_projects` with `status: "onHold"` to get the Someday/Maybe lists.
- `list_folders` gives the folder structure (work vs. personal)
- `list_tags` gives the **exact** tag names and which ones are on hold

**Look for existing matches for every harvested item.** Go from cheap and broad to targeted:
1. `get_project_tasks` for the 1–3 projects most of the items likely belong to, plus `get_inbox_tasks`. One call often surfaces most of the matches at once.
2. For items about someone who has a person tag (family, manager): `list_tasks` with `completed: false, tagNames: ["<Name>"]`. This finds "Check on dad after melanoma operation" when the session said "call Dad after his follow-up".
3. Keyword searches, **only for items still unmatched**: `list_tasks` with `completed: false` and `search: "<keyword>"`. **Use `completed: false`, not `taskStatus: "remaining"`.** The server's "remaining" filter only keeps Available and Blocked tasks, so it silently drops Next, Due Soon, and Overdue tasks, which are exactly the ones most likely to match. Search is one case-insensitive substring match on name and note, so run 1–3 short, distinctive keywords per item: a proper noun, product, or account name ("ESPP", "Powder House", "EOB", "Epic") rather than a phrase. Expect substring noise ("ski" also matches "skill"). The results include project, dates, and tags. Avoid the generic `search` tool for this, since it also returns every completed instance of recurring tasks.

Read `references/heath-omnifocus-conventions.md` the first time you run this skill in a session. It describes how Heath's projects and tags are used, with real examples.

**Decide what to do with each match:**
- **Already covered, nothing new** → skip it, and list it in the preview as "already in OmniFocus".
- **Covered, but the session added something** → propose an **edit** to that task instead of a new task:
  - *Append to the note* (`append_task_note`) with new details, decisions, numbers, links, or a checklist. This is the most common case. Start the appended block with `— Update from Claude Code · <YYYY-MM-DD>` so it's clear what changed.
  - *Fix the task* (`update_task`) when the session changed its facts: a hard deadline or unblock date emerged, or it's now urgent (flag).
  - *Propose a rename* when the name is vague and the session revealed the actual next action ("Figure out $500/mo childcare benefit" → "Enroll in Cleo childcare benefit"). **Renames are proposals only.** The name is Heath's own wording, so each rename needs his explicit, separate approval in the preview (see step 5). A general "yes, apply the changes" doesn't cover renames he didn't individually approve.
  - *Adjust tags* (`set_task_tags` with `mode: "add"` or `"remove"`), e.g. add `waiting` because it's now blocked, remove `waiting` because it's unblocked, or add a mode or person tag when the session changed how it'll get done (`calls` once it's "call Dad"). Don't add `claude` to existing tasks. That tag means "created by this skill", and the `— Update from Claude Code` header already marks edits.
- **The session resolved it** (the question got answered, or the thing got done) → if the resolution itself meets the verified-source bar (see below), propose **completing** it (`complete_task`), after appending the answer to its note so the result is kept. Then check whether the answer changes a *downstream* task. For example, "Figma HSA contribution if waived? → $0" means the note on "Make remaining HSA contribution" should now say the amount is $3,067.40.
- **The session contradicts it** (a different date, price, or plan) → don't silently overwrite. Show both values side by side in the preview and ask which is right. Heath's task may reflect something he knows and the session doesn't.
- **Made redundant by session work** (e.g. six "Install X" tasks now covered by a bootstrap script) → **offer to drop them** (`drop_task`). Say what makes them redundant, and **verify that claim** the same way as a fact for a note. Code that was written but never run doesn't make a task redundant. If a cheap check exists (`brew info --cask <name>`, rerunning the test, reading the file), run it. Propose drops only for the items the check confirms; list the rest as "not covered" in the note of the task that stays. (Real example: a session claimed six apps "all have casks", but a check showed Amphetamine has none and the DDPM cask name was wrong. Dropping those tasks would have lost two apps.) Like renames, drops are proposals, and each one needs Heath's explicit approval. Don't drop or complete anything unasked.
- **Heath refers to a task you can't find** ("put that with the monitor question") → say so in the preview and offer the closest candidates. Don't silently pick one.
- **No match** → it goes on to step 3 as a new task.

**Only add information that's been verified.** Anything written into an existing task (or a new one) must have been established in the session: read from a document, a file, a web page, or tool output, stated by Heath, or computed from those. Claude's recollection, guesses, and assumptions don't qualify. For each fact you plan to add, be able to name its source. Things that are useful but unconfirmed either stay out, or go in clearly labeled ("Unverified: the guide doesn't say whether the legal plan needs a Workday election"). If you can cheaply verify something now (reread the file, rerun the command, fetch the page), do that before writing it down.

When it's unclear whether an existing task is the same thing, treat that as a question for the preview. Don't guess either way. Respect Heath's existing structure: suggest edits to individual tasks, but don't propose merging or reorganizing tasks he created unless they're true duplicates.

## 3. Shape into next actions (the part that matters most)

A good task is **one visible, physical action that Heath can do in one sitting in one context**, without first deciding what the action is. It starts with a concrete verb: *Call, Email, Draft, Send, Buy, Pay, Book, Run, Review, Submit, Schedule, Ask, Read, Install, Decide.*

Run every candidate through the checks below.

**Too granular? Merge or demote to the note.** Signs:
- It's a step inside a procedure you'd follow in one sitting ("Compress the fork 10–20 times", "Wipe the stanchions")
- It's a value or setting, not an action ("VTI: 40%", "Bonds: 0%", "existing SPAXX cash")
- It's a fact or warning ("Keep lubricant away from the rotor")
- Several tiny edits share one sitting and one context ("Add LinkedIn link to README", "Add portfolio link to README", "Add Playbook link to README")
- It takes under two minutes and naturally happens as part of a neighboring task

→ Merge these into one task ("Add portfolio, LinkedIn, and Playbook links to profile README") and put the checklist, values, or procedure in the note. The note is where the detail goes. A detailed note is good; a detailed task list is not.

**Too vague or too big? Lift it to the next physical action.** Signs:
- "Figure out…", "Look into…", "Deal with…", "Handle…", "Work on…", "Think about…"
- It's an outcome that takes several sittings ("Set up laptop", "Launch the site")

→ Ask: *what is the very next thing Heath would physically do?* "Figure out remote work benefit" becomes "Read Figma remote-work benefit page on the intranet" or "Ask Erica how remote-work benefit reimbursement works". If the outcome really needs several actions over time, it's a **project** (see step 4). Capture only the actions that are clear now, usually 1–3. Don't try to plan every future step.

**Flat by default; subtasks sparingly.** Heath does use subtasks, but earlier Claude sessions leaned on them far too hard, so the bar is high. Default to flat tasks directly in the project. When an item seems to need children, first ask which of these it is:
- **Steps done in one sitting** (a procedure, a checklist, values to enter) → one task, with the steps in the note. *Never* subtasks. This is how the "Fox 36 leak check" (8 procedure steps as children) and the Roth swap (14 children, including "Use", "VTI: 40%") went wrong.
- **A real multi-step outcome** (several sittings, will take a while, has its own finish line) → propose a **new project**, with flat tasks.
- **A small outcome that's too small to be a project** (2–5 discrete actions in different sittings or contexts) → a parent task with a few children is fine. Heath's examples: "Book travel" → "Book hotel", "Book rental car"; "Figure out how to use dell monitor as a KVM switch" → "Buy USB-C to DisplayPort cable", "Buy Logitech unifying receiver", "Configure DDPM for KVM shortcut".
- **A conditional follow-up** ("check X; if Y, then do Z") → a parent with a short sequence of children also works ("Revisit OpenAI opportunity" → "Check whether the role is still posted", "If still open, send Laura one follow-up").

Limits when you do use subtasks: **one level only** (no grandchildren), **at most ~5 children**, and every child must itself pass the next-action test above (a verb and a physical action; no fragments, values, or warnings). Mark each parent with children as such in the preview so Heath can flatten it.

**Right-sized examples (from Heath's database):**
- "Pull EOBs from insurance portal" (note lists which EOBs and what to compare)
- "Call insurance to verify claim processing" (note lists the questions to ask)
- "Send first Figma paystub for payroll and tax true-up"
- "Set Figma traditional 401(k) contribution" (note holds the math)
- "Order Certified Marriage Certificate" (note holds the link and cost)
- "Pay AMEX"

**Sanity check on count:** a typical session produces **1–5 tasks**. More than about 8 almost always means you're too granular, so go back and merge. If the session really did produce a lot of work, it's probably one or two projects with a few next actions each, not a long flat list.

### Writing the task name
- Verb first, sentence case, usually under ~70 characters. Use Heath's terse style: "Pay AMEX", not "Remember to pay the AMEX credit card bill".
- Make it make sense weeks later out of context. Name the specific thing ("Email Laura follow-up on OpenAI Transparency Editor role", not "Send follow-up email").
- No trailing punctuation, no emoji, no "TODO:".

### Writing the note
Include everything Heath will need to act without reopening this session:
- **Why / context**: one or two lines
- **Specifics**: file paths, repo and branch names, commands, URLs, numbers, names, questions to ask, a checklist of sub-steps
- **Done when**: only if it's not obvious
- **Last line, always** (on new tasks): `— From Claude Code · <working directory> · <YYYY-MM-DD>`. Blocks appended to existing tasks use only the `— Update from Claude Code · <YYYY-MM-DD>` header, with no footer.

Plain text with line breaks and `•` bullets. Keep it scannable.

## 4. Place: project, tags, dates, flag

### Project
Pick the project where Heath would look for this task. Prefer the most specific active project whose name or existing tasks match the topic. Fall back to a broad single-action list (e.g. "Personal Admin") only when nothing specific fits and the item is a one-off.

Mark a placement as **uncertain** and ask about it in the preview when:
- Two or more projects are plausible
- No existing project fits, or the fit is a stretch
- The item is multi-step enough that it might deserve **its own new project**
- It's work-related and the work folder has no project for that topic yet
- It's dev-tool work (Claude Code skills, MCP servers, personal repos). This is decided case by case, so always ask.

OmniFocus/GTD system upkeep (cleaning up tags, adjusting perspectives, restructuring folders) goes in the **GTD System** project.

Never create a project, folder, or tag without Heath's explicit approval in the preview. For a proposed new project, suggest a name (an outcome phrase like "Launch Taskify skill"), a folder, and sequential vs. parallel.

Use `projectId`, not `projectName`, when creating tasks. The server matches names exactly and takes the first hit, which can be a dropped project with the same name.

If the project has an existing parent task or action group that a new task clearly belongs in (Heath's phase groups like "After first Figma paycheck", or a small outcome like "Set up laptop"), put it there with `parentTaskId` and show that in the preview. The one-level limit applies to what you create; nesting a flat task under Heath's existing parent is fine. Otherwise put it at the project's top level.

**Someday/maybe items** must never land in an active project, where they'd show up as available next actions. They belong in an **on-hold** project in the `Someday/Maybe…` folder. General ideas ("someday build a Raycast extension") go in **Ideas** (on hold, in Someday/Maybe). Things to watch or read go in **Watch/Read List**, restaurants in **Restaurants to Try**, music in **Music**. If none fits, ask. Someday items get no dates and only a topical tag if one is obvious.

### Tags
**Use existing tags whenever one fits.** Copy tag names exactly (case, emoji, spacing) from the live `list_tags` output. The MCP server **silently creates a new tag** for any name passed to `tags` that doesn't match exactly, and Heath's tag list already has accidental near-duplicates (`Writing`/`writing`). A typo would quietly add another one.

**A new tag is sometimes the right call**: an ongoing relationship Heath will keep raising things with (a new manager, a recurring collaborator), a new recurring context, or a new area of life. **One-off contacts never get a person tag.** Put the person's name in the task name and use a mode tag (`email`, `calls`) if one applies. When no existing tag fits and one would really help Heath filter, **propose** it in the preview. Give the name, the parent (e.g. under `People`), active or on-hold status, and one line on why no existing tag works. Don't create it until he approves. If he declines, drop the tag from those tasks rather than substituting something close but wrong. Before proposing, check that a near-duplicate doesn't already exist under a different case or spelling.

**Tag casing:** Heath's convention is **lowercase tags** (`writing`, `interview-prep`, `benefits`), with capitals only for people and other proper nouns (`Erica`, `Fox`, `Figma`, `Mac`, a specific place). New tag proposals follow this. When both a lowercase and a capitalized version of the same tag exist, use the lowercase one.

- Always add **`claude`**, which marks the task as coming from a Claude session.
- Add **0–2 more tags**, and only ones that help Heath find or filter the task:
  - **Blocked on something external** (a reply, a delivery, someone else's action, an event that has no known date): add **`waiting`**. It's an on-hold tag, so the task drops out of Next Actions and shows up in his Waiting For review. Name the task as the action Heath will take once it's unblocked, and say in the note what it's waiting on and when it's expected ("Waiting on: Bobbie confirming Dec 18–21, expected this weekend"). **The `waiting` tag alone is enough.** Heath checks his Waiting For list every few days, so don't also add a defer or planned date for an expected reply. Use a defer date *instead of* `waiting` only when the task is gated by the calendar rather than by a person or event ("leases open Oct 1").
  - **Needs a specific person** (to ask, discuss, or hand off): if Heath keeps an **agenda task** for them ("Questions for Erica"), add the question to that task's note instead of creating a new "Ask Erica…" task. Otherwise create the task with that person's tag under `People`, if one exists. One-offs get no person tag, as above.
  - **Mode**: `calls` for phone calls, `email` for email, `Errands` or its child tags for going somewhere
  - **Area**: `finance`, `taxes`, `benefits`, `health`, `career`, `car`, `cats`, `travel`, `home`, `subscriptions`, but only when the project doesn't already make the area obvious
- Don't use the priority tags (🔴P1/🟡P2/🟢P3) or `Projects/*` tags unless Heath asks.

### Dates
The default is **no dates**. Every date you add should reflect something real that the session established. Don't invent deadlines to seem helpful.

- **Defer** = the earliest date the task can or should be acted on. Use it when the task truly can't start earlier ("after first paycheck on 10/15") or shouldn't clutter the list until then. A known unblock date goes here.
- **Planned** = when Heath intends to do it, *and* where **soft deadlines** go. Use it when he said when he'll do it ("I'll do this Monday"), or when there's a "should do by" date without a hard consequence ("book by Nov 1, it tends to fill up", "prices go up after 10/12", "ideally before the trip"). Put the reason in the note ("Planned 11/1: camp books out; not a hard cutoff").
- **Due** = **hard deadlines only**, per GTD: miss it and something concrete happens (late fee, window closes, penalty, a commitment broken). Examples: a payment date, the last day of an enrollment window, a filing date, and **something a person asked Heath to deliver by a specific date or meeting** ("bring a 30/60/90 to our 1:1 Tuesday" → due Tuesday, before the meeting if its time is known; ask if it isn't). If it's not truly hard, it's a planned date. When you do set a due date and the task shouldn't appear until close to it, also set a defer a few days earlier. That's Heath's own pattern: "Pay AMEX" is deferred 10/16 and due 10/19. Put the consequence in the note ("Due 10/27: enrollment window closes; otherwise default PPO until Nov 2027").

**Lead time:** when the hard deadline is on an *outcome* that has lead time ("the plant must arrive by 10/10", "the form must be processed by…"), the action's date is the deadline minus that lead time. If the session didn't establish the lead time, propose a buffer, label it in the note as your buffer rather than a real cutoff, and make it a default Heath can change.

**Project-level dates:** a deadline on a whole outcome ("first readout end of October") goes on the **project**, not on its first next action.

Turn every relative date ("Friday", "next week", "end of month") into an absolute date from today's date. For "next week" with no specific day, use Monday.

**Always generate date values with the helper script.** Never pass a bare `YYYY-MM-DD`: the server parses it as UTC midnight, which is the previous evening in Pacific time.
```bash
~/.claude/skills/taskify/scripts/of_date.sh 2026-10-15 defer    # 00:00 local
~/.claude/skills/taskify/scripts/of_date.sh 2026-10-15 planned  # 09:00 local
~/.claude/skills/taskify/scripts/of_date.sh 2026-10-15 due      # 17:00 local
~/.claude/skills/taskify/scripts/of_date.sh 2026-10-15 14:30    # explicit time
```
It prints an ISO timestamp with the correct PDT or PST offset.

### Flag and estimate
- **Flag** only if Heath said it's urgent or important, or it blocks something time-sensitive this week. Otherwise leave it unflagged.
- **estimatedMinutes**: set it when you can estimate with reasonable confidence. It feeds his Quick Wins and Focus Time views. Skip it otherwise.

## 5. Preview and confirm

Show one compact preview before writing anything. Put updates to existing tasks first, then new tasks grouped by project:

```
**Updates to existing tasks**
A. "Figure out $500/mo childcare benefit" (Onboarding)
   ✎1 rename → Enroll in Cleo childcare benefit
   + append: $500/mo via Cleo, starts first full month after enrollment • needs a daycare invoice each month  [source: benefits guide PDF]
B. "Buy ski clothes for me and Fox" (Ski Season)
   + append: Fox sizes — helmet S (52–55cm), gloves kids M, pants 7/8
C. ✓ Complete "Confirm whether Figma makes any employer HSA contribution…"
   answered: $0 if medical is waived → appended to its note first
D. ⚠ Conflict "Buy ski pass" (due Tue 10/6)
   your note: prices go up 10/7 · session: price increase after 10/12 → (default: keep 10/6, the earlier date is safer)
E. "Questions for Erica" (Onboarding)
   + append: • Does the remote-work stipend cover a monitor?  (agenda task, not a new "Ask Erica…" task)
F. ✗1 drop "Install Maccy", ✗2 drop "Install SnagIt" (covered by bootstrap.sh; confirmed with brew info --cask)
   ℹ "Install Amphetamine" stays: no Homebrew cask, so the bootstrap doesn't cover it

**New · Onboarding** (Work — Figma)
1. Submit remote-work stipend claim in Navan
   tags: claude, benefits · defer Mon 9/28
   note: $1,000 one-time + $75/mo internet, receipts required [benefits guide] • …
2. Email Kylie O'Hara: does the waiver credit stack with the childcare benefit?
   tags: claude, email, benefits        (one-off contact → no person tag)

**New · Ski Season**
3. Book Heavenly ski school holiday camp for Fox
   tags: claude, Fox · planned Sun 11/1 (soft: camp books out)
4. Book VRBO near Heavenly Village for Dec 18–21
   tags: claude, waiting · note: Waiting on: Bobbie confirming dates, expected this weekend

**New · ❓ New project?** "Migrate status tool to Figma infra"
5. Draft migration plan doc for status tool
   tags: claude · planned Wed 10/7

**❓ New tag?** `Priya` under People (new skip-level; recurring 1:1s; 3 agenda items already)

Already in OmniFocus (no change)
• "Enroll in Figma ESPP at 15%…" (2026 Financial Plan)

Merged / left out
• "Add LinkedIn link", "Add portfolio link" → merged into one README task
• "Bonds: 0%" → moved into a note (a value, not an action)
• 9 clothing items → shopping list in the note on "Buy ski clothes for me and Fox"

I can do these now instead
• Update the README badge. Want me to do it before we wrap up?
```

**Keep the questions few.** Messy sessions can easily raise a dozen decisions, and AskUserQuestion allows 4 questions per call and 4 options per question. So:
- Give every item that has a sensible answer a **default in the preview**, marked `(default: …)`. Conflicts with an obvious answer, placements you're fairly sure of, and buffer dates all fall here. Heath only needs to speak up where he disagrees.
- Number every proposed **rename** and **drop** (✎1, ✎2, ✗1…) in the preview. Ask one question: "Apply renames/drops?" with options "All listed (Recommended)", "None", and "Other" for listing the ones he wants by number. Approving "All listed" after seeing each one counts as explicit approval. Anything not listed never happens.
- Save the remaining questions for decisions with **no safe default**: new projects or tags, true which-project toss-ups, unknown times, possible duplicates. Include a final "Apply defaults and write everything?" confirmation.
- One AskUserQuestion call is the goal, two at most. For "which project?" questions, include the plausible existing projects plus "Inbox (I'll file it later)", and put your best guess first, marked "(Recommended)".

If Heath edits something, update the plan and only re-preview if the changes were substantial.

## 6. Write and sync

- **Approved new tags first:** `create_tag` with the approved name, parent (`parentTagName`), and status. Only after that should any task reference the tag. Never let a tag come into being as a side effect of `tags` on a create call.
- **Then updates:** `complete_task` for tasks the session resolved (append the answer to the note first), `drop_task` for approved redundant tasks, `append_task_note`, `update_task` (dates, flag, and `name` only for renames Heath individually approved), and `set_task_tags` with `mode: "add"`/`"remove"` for each approved edit. Never use `update_task`'s `note` field to add detail, because it replaces the whole note. Use `append_task_note`.
- **New tasks:** group them by project and call `batch_create_tasks` once per project with `projectId` (or with `parentTaskId` for tasks going under an existing parent/group). Use `children` only for the approved small-outcome or conditional cases, one level deep. Tasks going to the Inbox get a batch with no project.
- **Approved new project:** `create_project` in the approved folder first, then add its tasks.
- Pass the `tags`, `note`, `deferDate`/`plannedDate`/`dueDate` (from the helper script), and `flagged`/`estimatedMinutes` fields as planned.
- After all writes, call `sync_database` **once**. You can also pass `sync: true` on the final batch instead.
- If a call fails partway, don't retry blindly. Check what was actually written (`list_tasks` with `search`, or `get_project_tasks`), then do only what's missing.

## 7. Report

Keep it short: which existing tasks were updated, how many new tasks were created in which projects, each task name with its `omnifocus:///task/<id>` link, and anything you left out and why. Don't repeat the whole preview.
