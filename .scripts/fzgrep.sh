#!/bin/bash
# source: https://gist.github.com/TripleDogDare/170cf93be8f4bd1f5dcbef26ad41246b
set -euo pipefail
# go get github.com/junegunn/fzf

BEFORE=10
AFTER=10
HEIGHT=$(expr $BEFORE + $AFTER + 3 )  # 2 lines for the preview box and 1 extra line fore the match

PREVIEW="$@ 2>&1 | grep --color=always -B${BEFORE} -A${AFTER} -F -- {}"

"$@" 2>&1 | fzf --height=$HEIGHT --reverse --preview="${PREVIEW}"
