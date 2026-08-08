#!/usr/bin/env bash
# Polls Claude plan usage (5-hour session + weekly) and pings via claude-notify
# when it crosses 80%, 85%, or 95%. Meant to run periodically (cron/systemd
# timer), independent of any particular Claude Code session.
#
# Usage: claude-usage-notify.sh

set -uo pipefail

THRESHOLDS=(80 85 95)
NOTIFY_BIN="/home/tejasr/.local/bin/claude-notify"
CLAUDE_BIN="/home/tejasr/.local/bin/claude"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude-usage-notify"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/state.json"
[ -f "$STATE_FILE" ] || echo '{"session_last":0,"session_notified":0,"week_last":0,"week_notified":0}' > "$STATE_FILE"

OUTPUT=$(timeout 45 "$CLAUDE_BIN" -p "/usage" 2>/dev/null)

SESSION_PCT=$(printf '%s' "$OUTPUT" | grep -oP 'Current session: \K[0-9]+(?=% used)' || true)
WEEK_PCT=$(printf '%s' "$OUTPUT" | grep -oP 'Current week \(all models\): \K[0-9]+(?=% used)' || true)

[ -z "$SESSION_PCT" ] && SESSION_PCT=-1
[ -z "$WEEK_PCT" ] && WEEK_PCT=-1

check_and_notify() {
    local label="$1" pct="$2" last_key="$3" notified_key="$4"
    [ "$pct" -lt 0 ] && return 0

    local last notified highest_crossed=0
    last=$(jq -r ".${last_key}" "$STATE_FILE")
    notified=$(jq -r ".${notified_key}" "$STATE_FILE")

    # A big drop since the last poll means the window reset — allow re-notifying.
    if [ "$pct" -lt "$last" ] && [ $((last - pct)) -gt 15 ]; then
        notified=0
    fi

    for t in "${THRESHOLDS[@]}"; do
        [ "$pct" -ge "$t" ] && highest_crossed=$t
    done

    if [ "$highest_crossed" -gt "$notified" ]; then
        "$NOTIFY_BIN" "Claude usage" "${label} usage is at ${pct}% (crossed ${highest_crossed}%)"
        notified=$highest_crossed
    fi

    jq ".${last_key} = ${pct} | .${notified_key} = ${notified}" "$STATE_FILE" > "${STATE_FILE}.tmp" \
        && mv "${STATE_FILE}.tmp" "$STATE_FILE"
}

check_and_notify "5-hour session" "$SESSION_PCT" "session_last" "session_notified"
check_and_notify "Weekly" "$WEEK_PCT" "week_last" "week_notified"

exit 0
