#################################
#
# Autocompletion
#
#################################

# Bash

## General

# enable extended pattern matching
shopt -s extglob

# The pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
# To unset use:
# shopt -u globstar
shopt -s globstar
# This script prevents wildcard (*) expansion, don't use
#source /etc/profile.d/bash_completion.sh

# If there are multiple matches for completion, Tab should cycle through them
# Disabled because to see the results you'll always select the first entry on tab
bind 'TAB: menu-complete'
#bind '"\C-j": menu-complete' # conflicts with .alacritty ScrollPageDown

# And Shift-Tab should cycle backwards
bind '"\e[Z": menu-complete-backward'
#bind '"\C-k": menu-complete-backward' # conflicts with .alacritty ScrollPageUp

# Display a list of the matching files
bind 'set show-all-if-ambiguous on'

# Perform partial (common) completion on the first Tab press, only start
# cycling full results on the second Tab press (from bash version 5)
bind 'set menu-complete-display-prefix on'


# Git
if [ -f ~/.git-completion.bash ]; then
   source ~/.git-completion.bash
fi

# Terraform
complete -C /usr/bin/terraform terraform

# Tmux

# Tmux autocompletion is contained in the .bash_completion file, which is read
# by default by `bash-completion`. This should be installed by default.
# In case that it is not:
# `sudo apt install bash-completion`
