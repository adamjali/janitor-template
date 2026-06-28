# Daily run — {{REPO}}

Follow this exactly. Idempotent + catch-up-safe (re-running never double-acts). All rules in `CLAUDE.md` + `memory/rules.md`. Helpers: `source scripts/lib.sh`. **Read the HARD INVARIANTS in CLAUDE.md first — they override everything.**

## 0 — Load state + ALL feedback channels
- Read `.routines/state.json` (`last_run`, `last_history_id`), `memory/rules.md`, `memory/precedents.md`, `memory/feedback_inbox.md`, `memory/open_issues.md`, `memory/pending_rules.md`.
- **Feedback channels — obey ALL, then clear (these are LAW):**
  1. **`feedback_inbox.md`** non-empty → the owner's instructions; obey this run, codify lasting ones into `rules.md`, clear to empty.
  2. **`#agent-feedback` label** — `list_ids "label:#agent-feedback"`: each is a message the owner replied-to / slapped the label on with an instruction. Read sender+subject (+ her reply snippet), OBEY it (keep / junk-full-shebang / file / pin / make-a-rule), codify lasting rules into `rules.md` ending `— [janitor, from the owner's feedback <ET>]`, then **remove the `#agent-feedback` label** (mark processed).
  3. **`#agent-undo` label** — `list_ids "label:#agent-undo"`: reverse the bot's last action on that message (un-trash / un-file / restore INBOX / un-read), record a NEGATIVE precedent ("don't redo X for this sender"), remove the label.
  4. **Reply to the digest** — `DONE`/instructions in the `Digest` thread → acknowledge that item / obey.
- **Pending rules** (`pending_rules.md`): any the owner approved via a channel → promote to `rules.md`; drop unapproved >30d.
- **Open-issues queue** (`open_issues.md`): service SESSION-owned items, surface owner-owned in the digest, leave BOT-owned (verify not STALE); `next-id` monotonic, cap >20 OPEN, DELETE on resolve (zero residue).

## 1 — Fetch the delta (only what changed)
- `users.history.list(startHistoryId=last_history_id)` → new/changed message ids.
- If it 404s (history expired, >~1wk gap) → fallback `q=newer_than:8d -in:trash -in:spam`, then re-anchor `last_history_id` from the latest message.
- Cap: if >150 new, do oldest 100 this run, note the rest. Skip ids already in `processed_ids.md`.

## 2 — Triage each new message (sender + subject; snippet only if ambiguous)
Decide one bucket (precedents in `rules.md` are priors):
- **Junk** (marketing/notification-with-dashboard/expired-code) → **full-shebang**: `trash`; if DKIM-pass + RFC-8058 one-click and not already in `unsubscribed.md` → `unsub_one_click` + record; `create_filter from:<sender> -> TRASH`; record sender. **Spam-flag ONLY actual scam / unsolicited / no-unsub / ignores-unsub** (legit-unwanted → unsubscribe+filter, never spam).
- **Keeper** → ensure it carries its **home label** (filters label most on arrival; you label what they missed using the `rules.md` map; unknown sender → best-judgment home + add a precedent, and if it's a clear settled keeper, `create_filter from:<sender> -> <Home>`).
- **Protected / starred / pinned / nostalgia / real-person / unsure** → leave in inbox, UNREAD; never trash/file. Unsure → flag for the digest.

## 3 — Read-state (conservative)
Mark **READ** (remove `UNREAD`) only: receipts (clean), OTP/codes, promotional, fluff. **Everything else stays UNREAD.** Security codes: never delete; aged+already-read may trash; fresh/unread → keep. When unsure → leave UNREAD.

## 4 — Two-speed file (labels-as-state; never on read)
For each labeled keeper:
- ⚪ **record-instant** class (statements/receipts/bills/confirmations) → file now: `removeLabelIds:["INBOX"]` (+ strip `CATEGORY_*`).
- 🔴 **important-window** class (people/job/work/medical/action/security/news-you-read) → keep in inbox until **owner moved it / owner said-so (feedback) / message ≥7d old** → then file (`remove INBOX`) + `addLabelIds:["zz-Surfacing"]`.
- **Never** file: `zz-Pinned`, starred, protected, nostalgia.

## 5 — Surface + acknowledge
- Items with `zz-Surfacing`, not acknowledged, <14d since first_seen → collect for the digest.
- **Acknowledged** = owner moved it / replied / dismissed-from-digest (reply `DONE`) — **NOT** merely read. On acknowledge → remove `zz-Surfacing`; if it was action-needed and not yet `addressed`, keep surfacing until handled.
- Item ≥14d, still un-acknowledged → judgment: plain FYI → remove `zz-Surfacing` (stays filed); action-needed → keep flagged, note in digest.

## 6 — Daily digest (email to self) — THE fleet-standard summary
- `send_self_email` subject `📬 Inbox Digest — <ET date>` (RFC-2047 encoded by the helper), body:
  - **Filed today** (counts by label) · **Still surfacing** (list, days-left + "reply DONE to dismiss") · **Needs you** (action items / flagged / unsure / open-issues owned by the owner) · **Junk cleared** (counts).
  - **🎓 Trash-chain transparency (REQUIRED, ~every 7th run):** what the 484 auto-trash filters + graduations ate since the last transparency report — per-sender counts + up to 5 sample subjects (`in:trash from:(graduated/filtered senders) after:<last-report>`), so the owner SEES what she no longer receives and can `#agent-undo` / reply to veto. Orphan filter or protected-sender hit → flag loudly.
- Apply the `Digest` label. Keep only the **latest** digest in the inbox; archive (`remove INBOX`) older `Digest` mail (rolling-replace). Reading it is NOT acknowledgement.
- Idempotent: a digest for today's date already exists → update/replace it, don't send a second.

## 7 — Persist + commit (last)
- Append a one-line record to `memory/run_status.md` (`<UTC> | ok|partial|fail | <N triaged> | notes`, keep last 30) + `memory/recent_log.md` (rolling, fold oldest half into `summary.md` past ~3000 words).
- Log acted ids to `processed_ids.md` (drop >30d). Update `precedents.md` (last ~200). Update `unsubscribed.md`/`blocklist.md`/`graduated_filters.md` as used.
- Write `.routines/state.json` with the new `last_history_id` + `last_run` **as the final step, only on success**.
- `git add -A && git commit` (routine push → `claude/**` → auto-merge Action → `main`).
- If the last 2 `run_status` entries are both `fail` → prepend a loud failure banner to the digest.
