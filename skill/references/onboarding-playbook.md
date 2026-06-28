# Onboarding Playbook — adding ANY email account to the fleet, at any stage

The person-first arc, distilled from the real Gmail (Apr 2026), Yahoo (Jun 2026), and Outlook/your-org
(Jun 2026) builds — including how to WORK WITH the person, not just the APIs. **Automation comes
LAST: the system must earn it by learning the person through real supervised work.**

## Operating discipline (applies at EVERY stage — this is law, learned the hard way)

- **Search the web + use context7 MCP throughout. Think deeply throughout.** Provider auth/APIs
  change constantly (app passwords died on Google & Microsoft; Graph endpoints moved to v1.0/beta;
  GitHub cron degraded in 2026). NEVER answer auth/API questions from memory — verify current facts
  with dated sources before designing anything.
- **Don't assume — actually check every single thing.** Probe the real account, run the real call,
  read the real headers. (We nearly built Outlook on a dead IMAP path; a 5-minute live consent test
  saved building a bot your-org would never allow.)
- **Explore how it ALL works together** — anything a part touches, what touches it, integrations,
  big picture AND every detail — BEFORE building. Plan thoroughly.
- **Reiterate and confirm back. NO implementation until you're on the same page with the person.**
  Present the plan, let them adjust, get the explicit green light. Ultrathink the design first.
- **Test everything before going live** ("do all, lemme see, then clean up, then go") — read tests,
  then write tests on throwaway items while they watch, then clean up the test artifacts.
- **Clean up thoroughly after every stage** — no scratch files, no test drafts, no orphan state.

## The stage ladder (detect where the account is; meet it exactly there)

`S1 CONNECT → S2 DISCOVER → S3 PROPOSE → S4 FULL RUN → S5 AUTOMATE → S6 FLEET`

A stalled stage = a Parked Item line (sync-history.md) with its stage + unblock condition.

---

### S1 — CONNECT (+ the opening interview)

**Tech:** research the provider's CURRENT auth (web+context7, dated sources), then the minimal
access that lets us read (and later act):

| Provider type | Auth path (verified Jun 2026 — RE-VERIFY at use) | Architecture it implies |
|---|---|---|
| Gmail / personal Google | OAuth client (GCP project) — **publish to Production or refresh tokens die in 7 days** | HTTPS API → cloud routine |
| Yahoo / IMAP-only | app password (Basic Auth lives here) | IMAP needs raw TCP:993 → GitHub Actions worker + **cloud-routine timer** (GitHub cron is unreliable: 0-for-3 here; claude-code-action#814 = schedule-triggered runs 401 → dispatch-only worker fired AS the owner via scoped PAT) |
| Personal Outlook/Microsoft | OAuth device-code, `/consumers`, public client (app passwords DEAD ~Oct 2024); refresh token ROTATES every use — persist it | HTTPS Graph → cloud routine |
| **Managed work/school tenant** | STOP — run the gate tests FIRST: app registration allowed? user consent allowed (or AADSTS90094)? Conditional Access? | Usually BLOCKED for personal bots (admin consent + FERPA-class concerns). Fallbacks: admin request (long shot), Power Automate janitor-lite, built-in rules. Don't build before the gates pass. |
| Second account on a known provider | reuse the proven recipe; new credentials only | clone the existing repo as template |

**Credentials are ALWAYS the person's job** (they click consent/generate passwords; walk them
click-by-click). Secrets: chmod 600 local, routine-prompt or repo-secret in cloud, NEVER in git.
Verify the connection with a read probe before declaring S1 done.

**Human:** the opening interview (conversational, not a form):
- What's this account FOR? (work/personal/junk-magnet/school — Yahoo being "~100% junk" changed everything)
- What's the GOAL? (inbox-zero? just less noise? surface-what-matters?)
- How AGGRESSIVE? ({{OWNER_NAME}}: "the more deletion the better" — but DISCOVER each person's setting; never assume)
- Unsubscribe appetite? (aggressive unsub of marketing? or conservative?)
- PROTECTED people/senders (family, boss, clients) — the never-touch list, hard law from day one.
- Anything they already know they hate/love about their current inbox?

### S2 — DISCOVER (read & analyze EVERYTHING — learn how THEY do email)

Read everywhere, not just inbox: **inbox + ALL folders/labels + archive + sent + drafts + trash +
spam/junk**. Full pagination (resultSizeEstimate lies; SEARCH lies on Yahoo — count for real).
Build:
- **Volume map**: counts per folder/label, oldest/newest, unread ratios.
- **Sender census**: top senders by volume, classified (human / transactional / marketing / scam).
- **Their organization fingerprint**: do they folder things? label? star? leave 10k unread? Which
  folders are alive vs fossils? Sent tells you who they actually write to (engagement = protect).
- **Spam/junk + trash tell you their tolerance**: what the provider already catches, what they
  manually delete (deliberate deletions = preferences revealed).
- Surface findings AS you go and ask about ambiguities ("400 from chess.com — keep or kill?",
  "this Archive folder from 2019 — alive or fossil?"). Their answers are rules being born.

(Real precedent: Yahoo discovery found 86k mail incl. a 76k junk archive; Gmail found 3.1k inbox
+ 4.4k stale archive label. The proposal writes itself once you truly know what's there.)

### S3 — PROPOSE (their structure, new, or hybrid — whatever fits THEM)

Present a complete written plan and confirm every piece (AskUserQuestion gates, their style):
- **Organization**: keep their existing structure / propose new / hybrid ("mirror Gmail labels,
  reuse archive subfolders" was a real hybrid choice). Their fingerprint from S2 decides the default.
- **Cleanup plan**: what gets trashed/archived/unsubscribed in the big first pass, with counts.
- **Ongoing rules draft**: the 5-bucket taxonomy (TRASH / SPAM / leave-read / leave-unread / FLAG)
  tuned to their interview + discovery answers; protected list; unsub criteria (one-click RFC 8058,
  DKIM-pass gate, **never require unsub-domain match — legit brands use ESPs**; scam self-signs
  DKIM → judgment decides WHO, never unsub scam).
- **Pace**: default = "watch the first batch → then autonomous" (proven pattern; offer it).
- NO ACTION until they green-light the plan. Reiterate it back; adjust; confirm.

### S4 — FULL RUN (supervised; THIS is where it learns them)

Execute the plan live, with them present:
- Test everything first on throwaway items (move one, trash one, draft one — they watch — then
  clean the test artifacts).
- First batch narrated and confirmed → then autonomous for the rest, surfacing uncertainties.
- **Capture EVERY decision** as precedents/rules — by the end, rules.md is not guesses, it's their
  actual recorded judgment. That's the asset automation inherits.
- Respect provider physics discovered en route (Yahoo: ONE connection, no reconnect-per-batch,
  UID MOVE ~100 cap, 7-day trash; Gmail: per-MINUTE query quota — pace; document every quirk in a
  TECHNICAL-NOTES.md as you hit them).
- Recovery nets always: trash-not-delete, undo logs for bulk ops, 30-day windows.
- Clean up thoroughly after (test drafts, scratch scripts → archived or deleted).

### S5 — AUTOMATE (only now — propose the skill + the daily bot)

They've seen it work and it knows them. Offer:
- **A daily bot** seeded with the learned rules.md/precedents — architecture per the S1 table
  (routine, or Actions+timer). **⭐ BUILD IT TO THE CANONICAL TEMPLATE — `triage-doctrine.md` §"Standard fleet-bot template — what EVERY bot has".** That section is the authoritative build spec (harmonized across all 4 bots 2026-06-18); instantiate ALL of it, don't reinvent. The floor (anything missing is a BUG): **3 feedback channels** (`#agent-feedback`/`#agent-undo` label-or-folder-or-category marker + `feedback_inbox.md` + reply-to-digest), **email-to-self `Digest`** (the standard summary — NOT a draft), **open-issues queue + `pending_rules.md` + graduation + trash-chain transparency**, **HARD INVARIANTS block + injection/attack awareness + PreToolUse `guard.sh` hook** (routine bots), the **memory-file floor + caps**, **delta-cursor + backlog sweep**, **visibility-first two-speed state-store**, and `auto-merge-claude.yml`. Reuse `~/emails/{{REPO}}` as the working reference implementation (or the sanitized `janitor-template`).
- **The fleet triage doctrine** (`references/triage-doctrine.md`, the canonical source) — full-shebang
  default for unwanted senders, spam-for-scam-only, mark-read-most-FYI, whole-company-unless-multi-use,
  receipts→file-don't-delete, real-people-personal always protected, preferences-fluid→re-confirm, and the
  **visibility-first delayed-filing** state machine. Fan it into the new bot's repo `CLAUDE.md` with
  `scripts/sync-fleet-rules.sh` (isolated bots read only their own repo files, never the local skill).
- **A command-center skill** (this skill IS the template) for their sessions.
- Deployment checklist: repo (private), secrets placed, scheduler created, one supervised live run
  green, THEN hands-off. Annual chores documented with loud-failure detection (tokens that expire).

### S6 — FLEET (steady state)

Register in context-map (stage column), health matrix picks it up, graduation pipeline starts
codifying settled senders (where the provider has a filter API — Gmail yes, Yahoo no → fast-path,
Outlook messageRules only WITH registry discipline). The bots queue session work via open_issues;
parked items resurface till done. Nothing grows forever; nothing fails silently.

---

## Working WITH the person (learned from the real thing — this is most of the job)

- **Ask at the start, throughout, and whenever appropriate** — but make questions COUNT (3-4
  options, concrete, with a recommendation marked). Batch small ones; never block on what a
  sensible default covers — but NEVER guess on preferences, money, or deletions.
- **Reiterate and confirm before each stage transition.** "Reiterate and confirm back to me" —
  present what you understood + what happens next; proceed on explicit yes.
- **Explain while doing** (zero-to-hero when they want it): analogies + the literal technical terms
  so they learn both. Some people want to write the IT email themselves — give them understanding,
  not just output. Never make them feel dumb for asking "wait, how did we run it before?"
- **Honesty over salesmanship**: say "this is a long shot" (your-org), "leave as-is, it's load-bearing"
  (token-trim), "my spec had 2 bugs, review caught them." Report failures loudly and plainly.
- **Their corrections are LAW** — codify immediately (rules.md / Never-graduate / fast-path), apply
  forever. When they say "nvm keep it like the original," revert cleanly and fully.
- **Always leave an audit trail** they can read later (commits, logs, summaries, queues) and an
  UNDO path for everything (vetoes, ungraduate, trash windows, undo logs).
