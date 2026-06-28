# Contributing

Thanks for your interest! This is a self-hostable daily email-cleanup bot template.

## Reporting issues
Open an issue with what you tried, your setup (provider, scheduler), and any error output — **redact tokens and email addresses** first.

## Changes
- Keep behavior provider-neutral where possible; document any provider-specific detail inline.
- **Never commit credentials.** `token.json`, `*.token`, and `client_secret*.json` are gitignored — keep it that way, and don't paste secrets into prompts or configs that get committed.
- The triage doctrine lives in `CLAUDE.md`; `scripts/sync-fleet-rules.sh` fans the shared rules into per-account files.
- Preserve the hard invariants (never permanently delete, never touch protected/starred mail, only email the owner).

## License
By contributing, you agree your contributions are licensed under the [MIT License](LICENSE).
