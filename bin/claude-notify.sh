#!/usr/bin/env bash
# Sends a desktop notification on this Ubuntu machine.
# Meant to be called by any Claude Code session, on this machine, right
# before it asks a question or needs permission to run something — so the
# user can be pinged instead of having to babysit the terminal.
#
# Usage:
#   claude-notify.sh                              # generic alert
#   claude-notify.sh "Title"                      # custom title
#   claude-notify.sh "Title" "Message body"        # custom title + body
#
# Exits 0 even if the notification couldn't be sent, so it never blocks
# whatever workflow called it.

set -uo pipefail

TITLE="${1:-Claude Code}"
BODY="${2:-Needs your input}"

# Claude sessions run as subprocesses of a terminal and don't always
# inherit a display/session bus (e.g. background shells, SSH sessions
# reattached to a local desktop). Fall back to this user's session bus.
export DISPLAY="${DISPLAY:-:0}"
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical -a "Claude Code" -i dialog-question "$TITLE" "$BODY" 2>/dev/null
fi

exit 0
