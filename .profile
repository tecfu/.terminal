#Allows ctrl-s, ctrl-q in Vim
stty -ixon > /dev/null 2>/dev/null

# Set vimode, Vim as editor
set -o vi

bind -x '"\C-p":git status'
#bind -x '"\e\k":printf "\033c"'

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

# Ignore commands leading with a space in terminal history
# https://stackoverflow.com/a/29188490/3751385
export HISTCONTROL=ignoreboth

# For jupyter-lab. See: https://stackoverflow.com/a/67130797/3751385
export PATH=$PATH:$HOME/.local/bin

# For Android studio
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
