#!/usr/bin/env bash
# Called by Claude Code's PermissionRequest hook (see ~/.claude/settings.json).
# Always sends a desktop toast via claude-notify.sh. Additionally sends a
# phone push via phone-notify.sh, but only when phone notifications are
# toggled on — see phone-notify-toggle.sh (off by default).
#
# Reads the hook's JSON payload from stdin.

set -uo pipefail

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/claude-notify/phone_hook_enabled"

MSG=$(jq -r '"Permission needed: " + (.tool_name // "a tool") + ((.tool_input.command // .tool_input.file_path // "") | if . != "" then " — " + . else "" end)' 2>/dev/null)
MSG="${MSG:-Waiting for your approval}"

/home/tejasr/.local/bin/claude-notify "Claude Code" "$MSG" >/dev/null 2>&1

if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "1" ]; then
    /home/tejasr/.local/bin/phone-notify -p high "Claude Code" "$MSG" >/dev/null 2>&1
fi

exit 0
