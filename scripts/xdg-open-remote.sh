#!/bin/bash
# Headless-ssh xdg-open shim: route http(s) URLs to the desktop browser through
# the ssh RemoteForward tunnel (port 15147). Everything else falls through to
# the real xdg-open. Sourced onto $PATH as ~/.local/bin/xdg-open by INSTALL.sh.
PORT="${PI_OPEN_PORT:-15147}"
for arg in "$@"; do
    case "$arg" in
        http://*|https://*)
            if curl -fsS -m 3 -X POST "http://127.0.0.1:$PORT/open?url=$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$arg")" >/dev/null 2>&1; then
                exit 0
            fi
            ;;
    esac
done
# env -u BROWSER: generic-mode /usr/bin/xdg-open re-runs $BROWSER, which points
# at pi-open.sh, whose own fallback execs xdg-open again -> infinite loop when
# the tunnel is down (the Sep 16 fork storm / OOM crash).
exec env -u BROWSER /usr/bin/xdg-open "$@"
