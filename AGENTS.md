# AGENTS.md

House rules for agents working in this repo. Distilled from three days of the
xAI Grok Bot team building and shipping a product live on stream.

Read this before your first action in a session. It overrides your defaults.

---

## The one rule

**Verification is the job. Writing code is the easy part.**

If you cannot demonstrate that your change works, you have not finished — no
matter how confident you are. Everything below is downstream of this.

---

## Before you write any code

1. **Reproduce first.** Run the app. Find the exact bug and the exact
   behaviour. Only once you can reproduce it do you understand the problem.
   Reproducing is not optional and not a formality — it is the test of whether
   you actually understood the report.
2. **Restate the task in your own words** before starting anything non-trivial.
   Say what you are about to do, what you are *not* going to do, and what you
   assumed. If the restatement is wrong, it is free to fix now and expensive to
   fix later.
3. **Say what you'd need to see to call it done.** One sentence. This becomes
   the proof you attach later.
4. **If asked to investigate, investigate.** "Don't open a PR yet, come back
   with what you think is going on" means exactly that. Do not start fixing
   because you spotted something on the way.

## While you work

- **Small changes.** One scoped concern per change. A large diff that "does
  everything" cannot be verified and cannot be reviewed.
- **Run the thing.** Not the type checker — the actual application. Click
  through it. Break it on purpose.
- **Fix the root cause, not the symptom.** Sink one level further rather than
  fix the sink. If you are about to write a workaround, say so out loud and
  explain why the real fix is out of scope.
- **Name the library.** If the task has an obvious well-known tool for it, use
  that tool. Do not hand-roll a worse version because nobody named it.
- **Don't invent content.** If you need real data — real names, real products,
  real endpoints — go look them up. Plausible placeholders that ship to users
  are worse than an error.
- **Never leak internal language into user-facing output.** Prototype names,
  codenames, TODO phrasing, your own reasoning. Check the strings a user sees.

## Before you open a PR

Attach proof. Every time.

| Change type | Required proof |
|---|---|
| UI | Screenshot, or a short screen recording of the flow |
| Backend / perf | Before-and-after numbers from an actual run |
| Bug fix | The reproduction, then the same steps passing |
| Refactor | The test or manual flow that proves behaviour is unchanged |

A PR with no proof is a draft, regardless of what the title says.

Also state, in the description:
- what you changed and why
- what you did **not** change that a reviewer might expect
- anything you are unsure about — flag it rather than hoping

## Code style

- **No comments as a crutch.** Agents reach for a comment to explain a
  workaround instead of removing the need for one. Those comments pile up until
  nobody can touch the file. If the code needs a comment to be understood,
  first try to make the code not need it. Reserve comments for genuine
  non-obvious *why* — never for *what*.
- **No dead code, no commented-out blocks, no "keeping this just in case."**
  Version control exists.
- **Delete the scaffolding you added to debug.** Debug panels, console logs,
  temporary flags. A feature flag is not security — if a code path must not be
  reachable by a user, it must not ship to the client at all.
- **Anything competitive or trust-bearing is server-authoritative.** Scores,
  balances, permissions, pricing, eligibility. If a determined user with
  devtools can change it, it does not belong on the client.
- **Treat any user-submitted text as hostile input.** Sanitize it. If it is
  going into a prompt, say so explicitly and guard against prompt injection.

## When you are corrected

This is the highest-value moment in the session. Do not just apply the fix.

1. Apply the fix.
2. Ask yourself what *general rule* this correction implies.
3. Write down the general rule — in this file, or in a skill.
4. **Strip the incident out of the rule.** The most common failure is baking
   today's specific bug into a permanent instruction. That makes the rule
   overfit and useless next time. Write the principle, delete the story.

Bad: *"When editing the checkout modal, always check the z-index of the banner
because it covered the button on 2026-03-04."*

Good: *"After any layout change, check that no existing interactive element is
covered."*

## When to stop and ask

Stop and ask a human when:

- the change touches auth, payments, permissions, or user data
- you are about to run a database migration or a destructive command
- you are about to deploy to production
- the task as written would require you to guess at a product decision
- you have tried the same approach twice and it failed both times

Do not loop. Two failed attempts on the same approach means the approach is
wrong, not that you need a third try. Report what you tried and what happened.

## When you're the one being asked for a status

Say what is done, what is in progress, and what is blocked. If nothing has
changed since the last update, say "no change" — do not manufacture a report.
On a scheduled check where there is genuinely nothing to report, stay silent.

---

## Vocabulary

Terms used in this repo and the rest of this pack.

- **Verification skill** — a reusable, deterministic way for an agent to
  exercise the app. See `agents/VERIFICATION.md`.
- **Feature map** — a machine-readable map of the app's features and flows so
  an agent can navigate without guessing.
- **Autopilot ladder** — how much autonomy a task is given: investigate → draft
  → autopilot → full autopilot. See `agents/ORCHESTRATION.md`.
- **Principle, not incident** — the rule for writing rules. See above.

---

## The short version

> Reproduce it. Run it. Prove it. Fix the cause, not the symptom.
> When you're wrong, write down the principle — not the story.

---

## Project rules

These rules sit with the field notes above. They are how this repository is coordinated. The map of specs, pictures, and status is [`PROJECT_INDEX.md`](PROJECT_INDEX.md).

**Grok is Project Director and the final coordinator.** Gemini is not joining development. Visual pass #17 is owned by the Cryptid World Builder (director ruling, 11 Nov). Do not start that pass on Gemini's behalf. It starts after #14 merges. The World Builder owns #17 (17a, 17b, 17c) and all town, visual, lighting, and VFX files. The Systems Architect owns scripting and systems: finishing #14, #15 rebirth, #16 tools, saves, and economy. After #14 merges, no edits to `TownBuilder` or other town visual files without coordinating with the World Builder.

Every agent:

1. **Read `PROJECT_INDEX.md` first.** Then read this file.
2. **Read the relevant specs and reference images before implementing.** Design specs are in `specs/`. Concept images are in `art/concepts/` and `art/vfx/concepts/`. `docs/spec-01.md`, `docs/spec-02.md`, `docs/spec-03.md`, and `art/style-guide.md` (v0.2) are superseded as design authority. The current style guide is `art/style-guide-v0.8.md`. The index says so. Do not treat a superseded file as the current decision.
3. **Check existing issues, pull requests, and branches for duplicates** before starting work.
4. **Follow the established standards.**
   - `docs/studio-ops-guide` §11 when that guide is in the repo. It is not in the repo today.
   - Server-authoritative gameplay. The client shows replicated state and sends intents. Cash, rolls, prices, rewards, and eligibility stay on the server.
   - `UITheme` for colour, type, and motion (`src/shared/UITheme.luau`). No magic numbers. Name constants in the config modules.
   - Versioned DataStore migrations. Do not rewrite a save in place. A new profile shape gets a new `dataVersion` and a migration. `Save.DATA_VERSION` on main is 9.
5. **Keep approved decisions unless a human explicitly authorises a change.** Flag conflicts in the index or the pull request. Do not resolve them while passing through.
6. **Record meaningful gameplay, architecture, or art changes** in the spec or the index, in the same change as the work.
7. **Give verification evidence before calling work done.** A merged pull request is not QA Passed. QA Passed requires a `qa/*-report.md` that says PASS. Nothing is Released until a publish has happened.

Precedence when sources disagree (also in the index):

1. Approved decisions and specs.
2. Verified implementation and tests.
3. Approved issues and acceptance criteria.
4. Historical or exploratory notes.

Keep intended, implemented, and verified behaviour in separate sections. The index does that.

Current build order: **#14** town v3, then **#15** rebirth, then **#16** `rbx_check`. **#18** the preview-kick fix is merged. **#17** visual pass 1 starts after #14 merges (17a sky + cobbles, 17b building shapes, 17c life + VFX) and is not blocked on #15 or #16. Do not skip #14.
