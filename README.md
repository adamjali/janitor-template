# janitor-template — a daily email-cleanup bot for any inbox

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A fully de-personalized, self-hostable copy of a production Gmail "janitor." It runs once a day, triages new mail, files it on a **visibility-first** schedule (you see important things first; records file instantly), keeps your inbox a clean waiting-room, sends you a **daily digest**, and **learns your preferences** over time. Plug in your own account + rules and go.

**Nothing is ever permanently deleted** (trash only, recoverable). It never touches starred / protected / "nostalgia" mail, and a `PreToolUse` hook (`.claude/hooks/guard.sh`) hard-blocks destructive operations even if the model errs.

## What it does each run
1. Fetches only new mail since last run (History API cursor). 2. Triages each: junk → trash + one-click unsubscribe + filter (spam only for actual scam); keeper → routes to its label-home. 3. Marks read **only** disposable noise (receipts/OTP/promo/fluff). 4. Files records instantly; holds important mail visible for a 7-day window, then files + surfaces it. 5. Sends you an email-to-self **📬 Digest** (filed / surfacing / needs-you / junk-cleared + trash-chain transparency). 6. Commits its memory so it learns.

## How you talk to it
- Reply to any email, slap the **`#agent-feedback`** label on it → the bot obeys + remembers next run. **`#agent-undo`** reverses its last action on a message.
- Or edit `memory/feedback_inbox.md`. Or reply `DONE` on a digest item to dismiss it.

## Setup
1. **OAuth** — create a Google Cloud OAuth client, enable the Gmail API, scopes `gmail.modify` + `gmail.settings.basic`; get a refresh token into `token.json` (gitignored — never commit it). Set `OWNER_EMAIL` to your address.
2. **Your rules** — edit `memory/rules.md`: your label-homes, your **protected** senders (family/financial/etc.), your **nostalgia** keeps. Create the labels in Gmail (incl. `#agent-feedback`, `#agent-undo`, `Digest`, and hidden `zz-Surfacing`/`zz-Pinned`).
3. **Test locally** — `export OWNER_EMAIL=you@example.com GMAIL_CLIENT_ID=… GMAIL_CLIENT_SECRET=… GMAIL_REFRESH_TOKEN=…; source scripts/lib.sh; get_access_token` then follow `PROMPT.md`.
4. **Deploy** — private repo + a daily scheduler (a Claude routine, or cron) with the OAuth creds in the prompt/env. One supervised run, then hands-off.

## Replace these placeholders
`{{OWNER_NAME}}` · `{{OWNER_EMAIL}}` (or the `${OWNER_EMAIL}` env var) · `{{GITHUB_OWNER}}` · `{{REPO}}` · `{{family}}` · plus the PROTECTED + NOSTALGIA lists in `memory/rules.md`.

## Files
`CLAUDE.md` (identity + invariants + the canonical fleet doctrine) · `PROMPT.md` (the daily procedure) · `memory/rules.md` (your sender→label map) · `scripts/lib.sh` (Gmail helpers, no pip deps) · `.claude/hooks/guard.sh` (hard safety) · `.github/workflows/auto-merge-claude.yml`.

_This is a generic template — no personal data. Adapt the providers/labels to your needs._
