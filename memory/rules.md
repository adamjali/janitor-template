# Rules + sender→label map — {{OWNER_NAME}}

Owner: **{{OWNER_NAME}}** ({{OWNER_EMAIL}}). This file is how the bot classifies senders + the standing rules. Preferences are fluid → honor the latest; `feedback_inbox.md` + the `#agent-feedback` label are LAW. **Fill in the {{placeholders}} for your account.**

## Sender → home label (define YOUR label-homes + the routing cues)
Edit to match the labels you create. Example homes (delete/rename freely):
- **Family & People** — any real individual (personal-domain, non-role address); your family/close contacts.
- **Financial** — banks / cards / pay / loans / investments you use.
- **Work & Legal** — employer, legal, government-work.
- **Job Search** — applications / recruiters / interviews (if applicable).
- **Medical** — providers, pharmacy, insurance.
- **School** — your institutions, transcripts.
- **Travel** — airlines / bookings you actually use.
- **Home & Bills** — utilities, transit, housing, phone + subscriptions/accounts.
- **Receipts** — order / shipping / payment confirmations.
- **News & Media** — newsletters you keep.
- **OTHER / unsure** → leave unlabeled in inbox, UNREAD, flag in digest.

## 🛡️ PROTECTED — never trash/file/unsub/spam/mark-read (FILL IN YOURS)
- Family / close contacts: `{{add their email addresses, one per line}}`
- Financial / work / school / medical / gov accounts (transactional streams); ALL real-person individuals; ⭐ starred mail; your user labels.

## ⭐ NOSTALGIA — always KEEP (never trash/file/mark-read), even if it looks like a dead account (FILL IN YOURS)
Old game / childhood / first-account / sentimental mail — set your own (the original owner kept e.g. Club Penguin, Minecraft, Pottermore). When unsure → keep + flag, never delete.

## 📖 Read-state (NARROWED)
Mark READ only disposable noise: receipts (clean) / OTP / promo / fluff. Everything else stays UNREAD. Security codes: aged+read may trash, fresh/unread keep. When in doubt → UNREAD.

## 🗑️ Unsubscribe / spam
Unsubscribe only on DKIM-pass + RFC-8058 one-click (never body links), once per sender (track in `unsubscribed.md`). Legit-unwanted → unsubscribe + trash-filter (NOT spam). Spam-flag only actual scam / unsolicited / no-unsub / ignores-unsub. `blocklist.md` for repeat offenders.

## 🎓 Fast-path (graduated senders) — mechanical, no re-deliberation
(empty — the bot populates this as senders settle to ≥3 identical unconditional calls across ≥3 runs)
