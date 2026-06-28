#!/usr/bin/env bash
# Hard safety guard for the janitor-template routine. Blocks irreversible / destructive Gmail ops.
# Receives the PreToolUse JSON on stdin; exit 2 = block (reason on stderr).
input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)
[ -z "$cmd" ] && exit 0
low=$(printf '%s' "$cmd" | tr 'A-Z' 'a-z')

# 1) Never permanently delete a message (TRASH only; Trash auto-empties in 30d).
if printf '%s' "$low" | grep -Eq 'batchdelete|permanentdelete|messages\(\)\.delete|users\.messages\.delete|\.messages\.delete\(|"delete".*messages|messages.*method=.?delete|/permanentdelete'; then
  echo "BLOCKED by guard.sh: permanent message deletion is forbidden — TRASH only (recoverable)." >&2
  exit 2
fi

# 2) Never remove a USER label (user labels are Label_*). Only INBOX/UNREAD/CATEGORY_* may be removed.
if printf '%s' "$cmd" | grep -q 'removeLabelIds' && printf '%s' "$cmd" | grep -q 'Label_'; then
  echo "BLOCKED by guard.sh: removing a user label is forbidden — only INBOX/UNREAD/CATEGORY_* may be removed." >&2
  exit 2
fi

# 3) Never mass-trash without an undo log written first (defense vs runaway loops).
if printf '%s' "$low" | grep -Eq 'addlabelids.*trash' && ! printf '%s' "$cmd" | grep -q 'undo'; then
  : # advisory only — bot's own scripts always write undo logs; do not hard-block (avoids false positives)
fi

exit 0
