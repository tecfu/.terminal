#################################
#
# Aliases
#
#################################
# aider
function aiderpop() {
  alacritty --class Aider,Aider -e aider "$@"
}

# bookmark
alias vm='bm'

# fzgrep
alias fzgrep='~/.terminal/scripts/fzgrep.sh'

# IP lookup
alias ipv4lookup='dig +short myip.opendns.com @resolver1.opendns.com'
alias ipv6lookup='ip -6 addr'

# xclip
# copy command output directly to clipboard
alias cb='xsel --clipboard --input'

# alacritty
alias dup='alacritty --working-directory=$(pwd) &'

# docker
alias dc='docker rm -f $(docker ps -aq) || true; docker ps -aq'

# aws cloudwatch log explorer
# usage: `output=$(aws-log-explorer --profile localstack --endpoint http://localhost:4566) && echo "$output" | nvim -`
alias aws-log-explorer='~/.terminal/scripts/aws-cloudwatch-explorer.sh'
alias aws-delete-log-groups='~/.terminal/scripts/aws-cloudwatch-delete-log-groups.sh'
