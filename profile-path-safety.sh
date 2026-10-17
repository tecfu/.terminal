#################################
#
# PATH safety — Volta shim recursion
#
#################################
# Sourced BEFORE the "if not interactive, return" guard in .profile/.bashrc, on
# purpose. `bash -lc`, `ssh host cmd` and other non-interactive login shells still
# run /etc/profile.d/volta.sh, and until 2026-10-17 that file put a second spelling
# of $VOLTA_HOME/bin (/usr/local/lib/volta/home/bin, a symlink farm) on PATH. Volta's
# shim scrubs only the *literal* "$VOLTA_HOME/bin" from a child's PATH when
# _VOLTA_TOOL_RECURSION is set — which every Volta-launched parent, including pi,
# exports — so the surviving alias resolves straight back to the shim, which does the
# same thing again. Result: `node` never returns and forks ~1,000 stopped processes
# per second (the 2026-10-17 incident: 7,500 processes, ~32 GB).
#
# Drop every PATH entry that IS $VOLTA_HOME/bin under another name. The canonical
# spelling stays, so volta's own scrub still removes it and a delegating shim fails
# loudly ("Node is not available") instead of looping. The real cure is the v2
# /usr/local/lib/volta/env in ~/device-config; this is the half that does not need
# root, and it is why no login shell of this user can re-create the bug.
#
# Checks are cheap and fork-free except one readlink per PATH entry (~2 ms each),
# paid only by login shells; scripts run by pi never get here at all.

# Normalize $VOLTA_HOME to its realpath, then prune every other spelling of bin/.
# Normalizing matters: /etc/profile.d/volta.sh (v1) exported VOLTA_HOME *as* the farm
# symlink, so the farm entry looked canonical and the real ~/.volta/bin was the
# alias — pruning alone would have kept the wrong one.
_volta_prune_alias_paths() {
    local volta_bin="$1" canon entry in out
    [ -n "$volta_bin" ] && [ -d "$volta_bin" ] || return 0
    command -v readlink >/dev/null 2>&1 || return 0
    canon=$(readlink -f "$volta_bin" 2>/dev/null) || return 0
    [ -n "$canon" ] || return 0
    if [ "$volta_bin" != "$canon" ]; then
        VOLTA_HOME="${canon%/bin}"
        export VOLTA_HOME
        volta_bin="$canon"
    fi
    in=":$PATH:"; out=""
    while [ -n "$in" ]; do
        in="${in#:}"
        [ -n "$in" ] || break
        entry="${in%%:*}"
        in="${in#"$entry"}"
        [ -n "$entry" ] || continue
        if [ "$entry" != "$volta_bin" ] && \
           [ "$(readlink -f "$entry" 2>/dev/null)" = "$canon" ]; then
            continue
        fi
        out="${out:+$out:}$entry"
    done
    PATH="$out"
    export PATH
}

_volta_prune_alias_paths "${VOLTA_HOME:-$HOME/.volta}/bin"

# The guard is only meaningful inside a single tool invocation. A top-level shell
# that inherits it (from pi, from `volta run`) takes Volta's delegate-to-system path
# instead of using its pinned node — which is the difference between an error
# message and a fork loop. Nothing a shell started by Volta needs this set.
unset _VOLTA_TOOL_RECURSION
