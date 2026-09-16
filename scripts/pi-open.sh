#!/bin/bash
# Remote-side helper: open a URL in the browser of the machine you SSH'd FROM.
# Requires ssh RemoteForward of port 15147 (see dotfiles .ssh/config) and the
# local remote-url-opener service. Falls back to xdg-open when the tunnel is
# not up (e.g. direct local use, or forwarded port taken by another session).
PORT="${PI_OPEN_PORT:-15147}"
if command -v curl >/dev/null 2>&1 && curl -fsS -m 3 -X POST "http://127.0.0.1:$PORT/open?url=$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$1" 2>/dev/null)" >/dev/null 2>&1; then
    exit 0
fi
# env -u BROWSER: generic-mode /usr/bin/xdg-open re-runs $BROWSER, which points
# back at this script -> xdg-open -> this script. Without unsetting it, a down
# tunnel forks a pi-open/xdg-open loop (the Sep 16 fork storm / OOM crash).
exec env -u BROWSER /usr/bin/xdg-open "$@"
