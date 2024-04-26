#################################
#
# Environment Variables
#
#################################

# prevent oh-my-bash from paging git results
export GIT_PAGER=""

# Ignore commands leading with a space in terminal history
# https://stackoverflow.com/a/29188490/3751385
export HISTCONTROL=ignoreboth

# For jupyter-lab. See: https://stackoverflow.com/a/67130797/3751385
export PATH=$PATH:$HOME/.local/bin

# For Android studio
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
