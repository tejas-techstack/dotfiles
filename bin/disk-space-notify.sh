#!/usr/bin/env bash
# Polls free disk space on a filesystem and pings via claude-notify when
# free space drops below 10% or 5%, and then again for every whole percent
# free below that (4%, 3%, 2%, 1%, 0%). Meant to run periodically
# (cron/systemd timer).
#
# Usage: disk-space-notify.sh [mountpoint]
#   mountpoint defaults to /

set -uo pipefail

MOUNTPOINT="${1:-/}"

# Descending: first crossing under 10% and 5% notify once each, then every
# percent free below that notifies again.
THRESHOLDS=(10 5 4 3 2 1 0)

NOTIFY_BIN="/home/tejasr/.local/bin/claude-notify"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/disk-space-notify"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/$(echo "$MOUNTPOINT" | tr '/' '_').json"
# notified=101 means "nothing notified yet" (above the highest threshold).
[ -f "$STATE_FILE" ] || echo '{"free_last":101,"notified_floor":101}' > "$STATE_FILE"

USED_PCT=$(df -P "$MOUNTPOINT" 2>/dev/null | awk 'NR==2{gsub("%","",$5); print $5}')
[ -z "${USED_PCT:-}" ] && exit 0
FREE_PCT=$((100 - USED_PCT))
AVAIL_HUMAN=$(df -Ph "$MOUNTPOINT" 2>/dev/null | awk 'NR==2{print $4}')

FREE_LAST=$(jq -r ".free_last" "$STATE_FILE")
NOTIFIED_FLOOR=$(jq -r ".notified_floor" "$STATE_FILE")

# Space freed up significantly since last poll (e.g. cleanup ran) — allow
# re-notifying if it drops again.
if [ "$FREE_PCT" -gt "$FREE_LAST" ] && [ $((FREE_PCT - FREE_LAST)) -gt 15 ]; then
    NOTIFIED_FLOOR=101
fi

lowest_crossed=101
for t in "${THRESHOLDS[@]}"; do
    if [ "$FREE_PCT" -le "$t" ]; then
        lowest_crossed=$t
    fi
done

if [ "$lowest_crossed" -lt "$NOTIFIED_FLOOR" ]; then
    "$NOTIFY_BIN" "Low disk space" "${MOUNTPOINT}: ${FREE_PCT}% free (${AVAIL_HUMAN} available)"
    NOTIFIED_FLOOR=$lowest_crossed
fi

jq ".free_last = ${FREE_PCT} | .notified_floor = ${NOTIFIED_FLOOR}" "$STATE_FILE" > "${STATE_FILE}.tmp" \
    && mv "${STATE_FILE}.tmp" "$STATE_FILE"

exit 0
