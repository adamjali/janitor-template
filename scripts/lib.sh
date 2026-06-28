#!/usr/bin/env bash
# {{REPO}} Gmail helpers (curl + python3 for JSON; no pip deps — routine-sandbox safe).
# Secrets come from env (set in the routine prompt body): GMAIL_REFRESH_TOKEN, GMAIL_CLIENT_ID, GMAIL_CLIENT_SECRET.
# Scopes: gmail.modify + settings.basic  (can trash, CANNOT permanently delete).
set -uo pipefail
API="https://gmail.googleapis.com/gmail/v1/users/me"
_ACCESS=""

pyget() { python3 -c "import sys,json;d=json.load(sys.stdin);print(d$1)" 2>/dev/null; }   # pyget '["field"]'

get_access_token() {
  _ACCESS=$(curl -sf -X POST https://oauth2.googleapis.com/token \
    -d client_id="$GMAIL_CLIENT_ID" -d client_secret="$GMAIL_CLIENT_SECRET" \
    -d refresh_token="$GMAIL_REFRESH_TOKEN" -d grant_type=refresh_token | pyget "['access_token']")
  [ -n "$_ACCESS" ] || { echo "FATAL: token refresh failed" >&2; return 1; }
}

gmail_api() {  # gmail_api METHOD PATH [json-body]
  local method="$1" path="$2" body="${3:-}"
  local args=(-sf -X "$method" -H "Authorization: Bearer $_ACCESS")
  [ -n "$body" ] && args+=(-H "Content-Type: application/json" -d "$body")
  for a in 1 2 3 4 5; do
    out=$(curl "${args[@]}" "$API$path") && { printf '%s' "$out"; return 0; }
    sleep $((a*a+1))   # backoff on 403/429/5xx
  done
  return 1
}

list_ids() {  # list_ids "<gmail q>"  -> message ids, paginated
  local q="$1" pt="" url
  while :; do
    url="/messages?maxResults=500&q=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$q")"
    [ -n "$pt" ] && url="$url&pageToken=$pt"
    resp=$(gmail_api GET "$url") || return 1
    printf '%s' "$resp" | python3 -c "import sys,json;[print(m['id']) for m in json.load(sys.stdin).get('messages',[])]"
    pt=$(printf '%s' "$resp" | pyget "['nextPageToken']"); [ -n "$pt" ] || break
  done
}

batch_modify() {  # batch_modify '<id1 id2 ...>' '["ADD"]' '["REMOVE"]'   (chunks of 1000)
  local ids=($1) add="$2" rem="$3" chunk
  for ((i=0;i<${#ids[@]};i+=1000)); do
    chunk=$(printf '"%s",' "${ids[@]:i:1000}"); chunk="[${chunk%,}]"
    gmail_api POST "/messages/batchModify" "{\"ids\":$chunk,\"addLabelIds\":$add,\"removeLabelIds\":$rem}" >/dev/null
    sleep 0.5
  done
}

get_or_create_label() {  # get_or_create_label "Name" [hide]  -> prints labelId
  local name="$1" hide="${2:-}" id
  id=$(gmail_api GET "/labels" | N="$name" python3 -c "import sys,json,os;[print(l['id']) for l in json.load(sys.stdin)['labels'] if l['name']==os.environ['N']]" | head -1)
  if [ -z "$id" ]; then
    local vis='"labelShow","messageListVisibility":"show"'; [ -n "$hide" ] && vis='"labelHide","messageListVisibility":"hide"'
    id=$(gmail_api POST "/labels" "{\"name\":\"$name\",\"labelListVisibility\":$vis}" | pyget "['id']")
  fi
  printf '%s' "$id"
}

create_filter() {  # create_filter "<gmail-from-query>" '["LabelId"]' '["INBOX","UNREAD"]'(optional removes)
  local q="$1" add="$2" rem="${3:-[]}"
  gmail_api POST "/settings/filters" "{\"criteria\":{\"query\":$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$q")},\"action\":{\"addLabelIds\":$add,\"removeLabelIds\":$rem}}" >/dev/null
}

unsub_one_click() {  # unsub_one_click "<https-url>"   (only after DKIM-pass + List-Unsubscribe-Post:One-Click verified by caller)
  curl -sf -X POST "$1" -H "Content-Type: application/x-www-form-urlencoded" --data "List-Unsubscribe=One-Click" -o /dev/null && echo "unsubbed: $1"
}

send_self_email() {  # send_self_email "Subject" "PlainBody"   (digest to the owner)
  local subj="$1" body="$2" esubj raw
  # RFC 2047 encoded-word so emoji/em-dash in the subject render correctly everywhere
  esubj="=?UTF-8?B?$(printf '%s' "$subj" | python3 -c "import sys,base64;print(base64.b64encode(sys.stdin.buffer.read()).decode())")?="
  raw=$(printf 'To: ${OWNER_EMAIL}\r\nFrom: ${OWNER_EMAIL}\r\nSubject: %s\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n%s' "$esubj" "$body" \
        | python3 -c "import sys,base64;print(base64.urlsafe_b64encode(sys.stdin.buffer.read()).decode())")
  gmail_api POST "/messages/send" "{\"raw\":\"$raw\"}" >/dev/null
}

get_history() {  # get_history "<startHistoryId>"  -> changed message ids (empty + rc!=0 signals 404/expiry -> caller falls back to newer_than:8d)
  gmail_api GET "/history?startHistoryId=$1&historyTypes=messageAdded" \
    | python3 -c "import sys,json;d=json.load(sys.stdin);[print(m['message']['id']) for h in d.get('history',[]) for m in h.get('messagesAdded',[])]"
}

profile_history_id() { gmail_api GET "/profile" | pyget "['historyId']"; }   # current historyId to re-anchor
