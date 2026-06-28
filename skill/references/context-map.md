# Context map — YOUR fleet (fill this in)

The command-center skill reads this to know your bots. One row per account.

## Fleet at a glance
Stage ladder: `S1 CONNECT → S2 DISCOVER → S3 PROPOSE → S4 FULL RUN → S5 AUTOMATE → S6 FLEET`

| System | Stage | Worker | Scheduler | Repo (origin = truth) | Local clone |
|---|---|---|---|---|---|
| {{account-1}} | S? | Claude routine / GitHub Actions | {{ROUTINE_ID or Actions+timer}} | `{{GITHUB_OWNER}}/{{REPO}}` (private) | `{{path}}` |

## Scheduler identifiers
- **{{account-1}} daily**: `{{ROUTINE_ID}}` — model `opus`, cron `0 12 * * *` UTC (≈8 AM ET). Pushes `claude/**` → `auto-merge-claude.yml` → main.

## Credentials & annual chores (all should fail LOUDLY when dead)
| Secret | Where it lives | Scope | Expiry / rotation |
|---|---|---|---|
| OAuth refresh token | the routine prompt body + `token.json` (gitignored) | minimal (mail.modify + settings) | rotate on revoke; document the steps |

## Accounts
- {{account-1}}: `{{OWNER_EMAIL}}` · GitHub: `{{GITHUB_OWNER}}`

## Provider notes (keep what applies)
- **Gmail** — HTTPS API → cloud routine OK. History-API cursor. Native filters (graduation).
- **IMAP (Yahoo/etc.)** — raw TCP → must run on GitHub Actions (routines can't open :993); a timer routine dispatches it. No filter API → fast-path graduation in text. Mind login throttling (one persistent connection).
- **Microsoft Graph (Outlook)** — OAuth2 (app-passwords dead); refresh token rotates each run; per-folder delta cursor; categories as label-analog.
