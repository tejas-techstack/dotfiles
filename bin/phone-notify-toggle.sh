#!/usr/bin/env bash
# Toggles whether Claude Code permission-request notifications also push to
# the phone (in addition to the desktop toast, which always fires). Off by
# default: permission requests happen often and most aren't worth a phone
# buzz, so phone push is something you switch on for a specific stretch
# (e.g. a long unattended run) rather than a permanent feed.
#
# State is read by claude-permission-notify.sh on every PermissionRequest
# hook firing.
#
# Usage:
#   phone-notify-toggle on
#   phone-notify-toggle off
#   phone-notify-toggle status   (default if no args)

set -uo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude-notify"
STATE_FILE="$STATE_DIR/phone_hook_enabled"
mkdir -p "$STATE_DIR"

ACTION="${1:-status}"

case "$ACTION" in
    on)
        echo 1 > "$STATE_FILE"
        echo "phone notifications for permission requests: ON"
        ;;
    off)
        echo 0 > "$STATE_FILE"
        echo "phone notifications for permission requests: OFF"
        ;;
    status)
        if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "1" ]; then
            echo "phone notifications for permission requests: ON"
        else
            echo "phone notifications for permission requests: OFF"
        fi
        ;;
    *)
        echo "usage: phone-notify-toggle [on|off|status]" >&2
        exit 1
        ;;
esac
