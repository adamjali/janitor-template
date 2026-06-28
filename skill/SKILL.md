---
name: janitor
description: Sync, check, update, or interact with your EMAIL FLEET — the daily email-cleanup bot(s) built from this template. Catches up on what each bot did (memory, run status, graduations, open-issues, flagged items, unsubscribes), services SESSION-owned queue items, surfaces actionables, tidies the workspace, and helps you modify a bot (rules, pause/resume, run now, rotate credentials) — and onboards NEW accounts via the S1→S6 ladder. Use for "check my email(s)", "how's my janitor", "sync janitor", "run/pause it", "onboard <email>", "clean my inbox".
---

# janitor — email-fleet command center (generic template)

This is the **session-side command center** for a fleet of daily email-cleanup bots built from this template. It is provider-neutral (Gmail / IMAP / Microsoft Graph). Fill in your fleet in `references/context-map.md`.

## What it does
- **Sync/check** — pull each bot's repo, health-check its scheduler, read its `memory/` + cursor, summarize what it did since last check (triaged / flagged / graduated / unsubscribed / open-issues / failures).
- **Service the queue** — bots leave SESSION-owned items in `memory/open_issues.md`; execute the reversible ones (with attribution), surface the owner-owned ones, leave bot-owned waits.
- **Modify a bot** — add a rule, pause/resume, run-now, ungraduate a sender, rotate a credential — always confirming destructive/credential-adjacent steps.
- **Onboard a new account** — when the owner mentions a new inbox, follow `references/onboarding-playbook.md` (S1 CONNECT → S2 DISCOVER → S3 PROPOSE → S4 FULL RUN → S5 AUTOMATE → S6 FLEET). Automation comes LAST, earned by supervised work. **Build every new bot to the canonical template** in `references/triage-doctrine.md` §"Standard fleet-bot template".

## Doctrine (the canonical behavior every bot inherits)
`references/triage-doctrine.md` is the single source of truth — full-shebang for unwanted senders, spam-for-scam-only, read-state narrowed, nostalgia/protected always kept, visibility-first two-speed filing, email-to-self digest, `#agent-feedback`/`#agent-undo` channel, open-issues queue, graduation + trash-chain transparency, hard invariants + injection awareness, PreToolUse `guard.sh`. **Edit it once, then fan it into every bot's `CLAUDE.md`** with `scripts/sync-fleet-rules.sh` (the bots read only their own repo files at runtime).

## Operating rules
- **Auto-execute** safe/reversible items (memory pruning, workspace cleanup, reversible queue items). **Ask** (Approve/Modify/Skip) for rule changes, prompt edits, scheduler changes, credential-adjacent actions. **Never** touch starred/protected mail, widen a credential scope, or commit email content.
- Attribution: memory lines end `— [session <ET timestamp>]`; commits prefixed `[session]`.
- Multi-device safe: origin/main is truth — pull at start, push at end.

## Files
`references/triage-doctrine.md` (canonical behavior) · `references/onboarding-playbook.md` (the S1→S6 recipe for any provider) · `references/context-map.md` (YOUR fleet: accounts, repos, scheduler IDs, credential locations — fill it in). The bot template itself is the parent directory (`../`).
