#!/usr/bin/env bash
# volta-path-doctor.sh — prove that `node` on this machine cannot fork-loop.
#
# Why this exists (2026-10-17): 7,500 stopped `node` processes, each the child of
# the previous, in a linear chain. Not a leak — a Volta shim recursion:
#
#   * ~/.volta/bin/node is a symlink to volta-shim, and /etc/profile.d/volta.sh
#     (device-config expose_to_root) put a SECOND spelling of that directory,
#     /usr/local/lib/volta/home/bin, on PATH while ~/.terminal/profile-env-public.sh
#     overrode VOLTA_HOME back to $HOME/.volta.
#   * When a Volta-launched parent (pi, an npm script) exports
#     _VOLTA_TOOL_RECURSION=1, the shim refuses its pinned image, scrubs the
#     literal "$VOLTA_HOME/bin" out of PATH, and looks for a "system" node. The
#     alias spelling is still there, resolves to the shim, and the shim does the
#     same thing: one fork per level, ~1,000 levels/second, forever.
#
# So: a PATH entry that is $VOLTA_HOME/bin under another name is a bug, and this
# script says so in words, then proves the loop is gone by running `node` WITH the
# guard set — bounded, and cleaned up even if it does recurse.
#
# Usage: volta-path-doctor.sh [shim-dir]      default: ${VOLTA_HOME:-$HOME/.volta}/bin
# Exit:  0 clean · 1 alias on PATH or recursion detected · 2 cannot check
set -u

SHIM_DIR="${1:-${VOLTA_HOME:-$HOME/.volta}/bin}"
CANON=$(readlink -f "$SHIM_DIR" 2>/dev/null) || CANON=""
if [ -z "$CANON" ] || [ ! -d "$CANON" ]; then
  echo "FAIL: no Volta shim dir at $SHIM_DIR (is volta installed?)" >&2
  exit 2
fi

echo "VOLTA_HOME=${VOLTA_HOME:-<unset>}"
echo "shim dir  =$SHIM_DIR -> $CANON"
echo "guard     =${_VOLTA_TOOL_RECURSION-<unset>}"

# ---- 1. audit PATH for alias spellings -------------------------------------
dups=0
oldifs=$IFS; set -f; IFS=:
for entry in $PATH; do
  [ -n "$entry" ] || continue
  if [ "$entry" != "$SHIM_DIR" ] && \
     [ "$(readlink -f "$entry" 2>/dev/null)" = "$CANON" ]; then
    echo "ALIAS: $entry is $CANON, spelled differently from $SHIM_DIR"
    dups=$((dups + 1))
  fi
done
IFS=$oldifs; set +f
[ "$dups" = 0 ] && echo "PATH: no alias spelling of the shim dir"

# ---- 2. probe: node with the recursion guard set ---------------------------
# Runs in its own session so the whole tree can be stopped, then killed, even if
# it is growing while we kill it. A single `kill -9 -PGID` leaks: while the wave
# is still walking the tree, the surviving levels keep forking (this cost 6,800
# stray processes the first time). STOP first, then loop the KILL.
if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not on PATH; cannot probe"
  exit "$([ "$dups" = 0 ] && echo 0 || echo 1)"
fi

GID_FILE=$(mktemp /tmp/volta-doctor.XXXXXX)
OUT_FILE=$(mktemp /tmp/volta-doctor.XXXXXX)
trap 'rm -f "$GID_FILE" "$OUT_FILE"' EXIT

setsid bash -c "echo \$\$ >'$GID_FILE'; exec env -i HOME=\"\$HOME\" TERM=dumb \
  PATH=\"\$PATH\" VOLTA_HOME=\"${VOLTA_HOME:-$CANON}\" _VOLTA_TOOL_RECURSION=1 \
  node --version" >"$OUT_FILE" 2>&1 &
disown 2>/dev/null || true

# 1s is plenty: a healthy node answers in ~20ms, the loop made 1,000+ procs in 1s.
sleep 1
GID=$(cat "$GID_FILE" 2>/dev/null)
if [ -z "$GID" ]; then
  echo "FAIL: probe never reported its process group" >&2
  exit 2
fi
peak=$(ps -eo pgid= | awk -v g="$GID" '$1 == g' | wc -l)
for _ in 1 2 3 4 5; do
  kill -STOP "-$GID" 2>/dev/null
  kill -9 "-$GID" 2>/dev/null
  sleep 0.3
  [ "$(ps -eo pgid= | awk -v g="$GID" '$1 == g' | wc -l)" = 0 ] && break
done
left=$(ps -eo pgid= | awk -v g="$GID" '$1 == g' | wc -l)
result=$(head -c 40 "$OUT_FILE" | tr '\n' ' ')

if [ "$peak" -gt 2 ]; then
  echo "RECURSION: $peak processes in 1s (no output) — node re-execs itself"
  echo "           $left still alive; clean up with: kill -9 -$GID"
  exit 1
fi
echo "PROBE: ok — ${result:-<no output>} ($peak proc, $left leaked)"
[ "$dups" = 0 ] || exit 1
exit 0
