# 📬 janitor — a complete, self-contained email-cleanup system (shareable template)

A fully de-personalized copy of a production email-janitor fleet. **Everything you need is in this one folder** — the daily bot, the command-center skill, the canonical behavior doctrine, and the onboarding recipe. No personal data anywhere; plug in your own account + preferences and go.

## What's in here
```
janitor-template/
├── PACKAGE.md            ← you are here (start here)
├── README.md             ← the BOT: what it does + setup
├── CLAUDE.md             ← bot identity + HARD INVARIANTS + the full doctrine (read every run)
├── PROMPT.md             ← the bot's daily procedure (Phases 0–7)
├── scripts/lib.sh        ← Gmail API helpers (curl + python3, no pip deps)
├── memory/               ← the bot's brain (rules.md = your sender→label map; rest are state, start empty)
│   ├── rules.md          ← ⭐ EDIT THIS: your labels, protected senders, nostalgia keeps
│   └── … open_issues, pending_rules, precedents, surfacing, run_status, etc. (caps documented in PROMPT.md)
├── .claude/              ← settings.json + hooks/guard.sh (PreToolUse hard-safety: blocks delete / label-removal)
├── .github/workflows/    ← auto-merge-claude.yml (routine pushes → main)
├── .routines/state.json  ← the delta cursor (set on first run)
└── skill/                ← the COMMAND-CENTER (for your Claude sessions to manage the fleet)
    ├── SKILL.md          ← /janitor: sync, check, modify, onboard new accounts
    └── references/
        ├── triage-doctrine.md     ← ⭐ the canonical behavior (the single source of truth)
        ├── onboarding-playbook.md ← the S1→S6 recipe to add ANY new account/provider
        └── context-map.md         ← ⭐ EDIT THIS: your fleet (accounts, repos, scheduler, credentials)
```

## How it works (one paragraph)
Once a day the bot fetches only new mail (delta cursor), triages each message (junk → trash + one-click unsubscribe + filter; keeper → routes to its label-home), marks read **only** disposable noise, files records instantly but holds important mail **visible for a 7-day window** before filing + surfacing it, and **sends you an email-to-self `📬 Digest`** (filed / surfacing / needs-you / junk-cleared + trash-chain transparency). It **never deletes** (trash only), never touches starred / protected / nostalgia mail, and a `guard.sh` hook hard-blocks destructive operations. You teach it by replying to any email + applying the **`#agent-feedback`** label (or `#agent-undo` to reverse) — it obeys and remembers.

## Quick start
1. **Read** `README.md` (bot setup) — create an OAuth client, get a refresh token into `token.json` (gitignored), set `OWNER_EMAIL`.
2. **Edit** `memory/rules.md` — your label-homes, protected senders, nostalgia keeps. Create the labels in your mailbox (incl. `#agent-feedback`, `#agent-undo`, `Digest`, hidden `zz-Surfacing`/`zz-Pinned`).
3. **Test** locally (follow `PROMPT.md`), then **deploy** as a private repo + daily scheduler.
4. To run a **fleet** or **onboard more accounts**, use `skill/` (fill in `skill/references/context-map.md`, follow the onboarding playbook, build each new bot to the doctrine's "Standard fleet-bot template").

## Placeholders to replace
`{{OWNER_NAME}}` · `{{OWNER_EMAIL}}` · `{{GITHUB_OWNER}}` · `{{REPO}}` · `{{ROUTINE_ID}}` · `{{ENV_ID}}` · `{{family}}` · the PROTECTED + NOSTALGIA lists in `memory/rules.md` · your fleet rows in `skill/references/context-map.md`.

_Generic template — no personal data. Adapt providers/labels/rules to your needs. Built for Claude Code (or any agent that can run Bash + the mail API)._
