#!/usr/bin/env bash
# Sends a detailed push notification to this user's phone via ntfy
# (https://ntfy.sh), for messages too long/important for a desktop toast.
# Meant to be called by any Claude Code session, or any script on this
# machine, for things worth interrupting the user away from their desk for.
#
# Config lives outside this repo (this repo is public) at
# ~/.config/claude-notify/phone.env, which must set NTFY_TOPIC to a private,
# unguessable topic name. Generate one with:
#   mkdir -p -m 700 ~/.config/claude-notify
#   { echo "NTFY_TOPIC=$(uuidgen)"; echo "NTFY_SERVER=https://ntfy.sh"; } > ~/.config/claude-notify/phone.env
#   chmod 600 ~/.config/claude-notify/phone.env
# Then subscribe to that same topic in the ntfy app on your phone.
#
# Usage:
#   phone-notify.sh "Title" "Detailed message body"
#   phone-notify.sh -p high -g warning "Title" "Detailed message body"
#
# Options:
#   -p PRIORITY   min|low|default|high|urgent (default: default)
#   -g TAGS       comma-separated ntfy tags/emoji shortcodes (e.g. "warning,computer")
#
# Exits 0 even if the notification couldn't be sent, so it never blocks
# whatever workflow called it.

set -uo pipefail

PRIORITY="default"
TAGS=""

while getopts ":p:g:" opt; do
    case "$opt" in
        p) PRIORITY="$OPTARG" ;;
        g) TAGS="$OPTARG" ;;
        *) ;;
    esac
done
shift $((OPTIND - 1))

TITLE="${1:-Claude Code}"
BODY="${2:-Needs your input}"

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/claude-notify/phone.env"
if [ ! -f "$CONFIG_FILE" ]; then
    exit 0
fi
# shellcheck source=/dev/null
source "$CONFIG_FILE"

[ -z "${NTFY_TOPIC:-}" ] && exit 0
NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"

curl -fsS -m 10 \
    -H "Title: ${TITLE}" \
    -H "Priority: ${PRIORITY}" \
    ${TAGS:+-H "Tags: ${TAGS}"} \
    -d "${BODY}" \
    "${NTFY_SERVER%/}/${NTFY_TOPIC}" >/dev/null 2>&1

exit 0
