#Allows ctrl-s, ctrl-q in Vim
stty -ixon > /dev/null 2>/dev/null

# Set vimode, Vim as editor
set -o vi
#
# Globstar: The pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
# To unset use:
# shopt -u globstar
shopt -s globstar

############################
# COMMANDS FOR DESKTOP ENV
############################

# Get remote ip address
alias ipv4lookup='dig +short myip.opendns.com @resolver1.opendns.com'
alias ipv6lookup='ip -6 addr'

source /etc/profile.d/bash_completion.sh

if [ -f ~/.git-completion.bash ]; then
   source ~/.git-completion.bash
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

complete -C /usr/bin/terraform terraform
