#!/bin/bash
##################################
#
# Usage:
#
# - Bash
# $ cat some-json.json | ./stringify-json.sh
#
# - Vim
# :'<,'>!./stringify-json.sh
#################################


input=$(cat)

echo $input | jq | sed 's/"/\\"/g' | echo "\"$(cat)\""
