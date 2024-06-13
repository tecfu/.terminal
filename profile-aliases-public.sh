#################################
#
# Aliases
#
#################################

# bookmark
alias vm='bm'

# fzgrep
alias fzgrep='~/.terminal/scripts/fzgrep.sh'

# IP lookup
alias ipv4lookup='dig +short myip.opendns.com @resolver1.opendns.com'
alias ipv6lookup='ip -6 addr'

# xclip
# copy command output directly to clipboard
alias cb='xclip -selection clipboard'

# alacritty
alias dup='alacritty --working-directory=$(pwd) &'

# docker
alias dc='docker rm -f $(docker ps -aq) || true; docker ps -aq'
