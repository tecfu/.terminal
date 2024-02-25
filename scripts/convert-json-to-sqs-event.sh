#!/bin/bash
#################################
#
# Usage
#
# - Bash
# $ cat json-array.json | ./convert-json-to-sqs-event.sh
#
# - Vim
# : '<,'>!./convert-json-to-sqs-event.sh
#################################

input=$(cat)
epoch=$(date +%s)
header=$(echo '{"Records": ')
# from: https://stackoverflow.com/a/41433037/3751385
body=$(echo $input | jq --arg START $epoch '($START | tonumber) as $s
  | to_entries
  | map({messageId: ($s + .key), "body": (.value | tojson | sub("\""; "\"")) })')
footer=$(echo '}')
echo $header$body$footer | jq .
