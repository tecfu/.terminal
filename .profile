###############################################################################
#
# Misc Config
#
###############################################################################
#Allows ctrl-s, ctrl-q in Vim
#stty -ixon > /dev/null 2>/dev/null

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


###############################################################################
#
# Vi Mode Related
#
###############################################################################

# Set vimode, Vim as editor
set -o vi

# Macros to enable yanking, killing and putting to and from the system clipboard in vi-mode. Only supports yanking and killing the whole line.
# see: https://unix.stackexchange.com/a/595798/146921
paste_from_clipboard () {
  local shift=$1

  local head=${READLINE_LINE:0:READLINE_POINT+shift}
  local tail=${READLINE_LINE:READLINE_POINT+shift}

  local paste=$(xclip -out -selection clipboard)
  local paste_len=${#paste}

  READLINE_LINE=${head}${paste}${tail}
  # Place caret before last char of paste (as in vi)
  let READLINE_POINT+=$paste_len+$shift-1
}

yank_line_to_clipboard () {
  echo $READLINE_LINE | xclip -in -selection clipboard
}

kill_line_to_clipboard () {
  yank_line_to_clipboard
  READLINE_LINE=""
}

bind -m vi-command -x '"P": paste_from_clipboard 0'
bind -m vi-command -x '"p": paste_from_clipboard 1'
bind -m vi-command -x '"yy": yank_line_to_clipboard'
bind -m vi-command -x '"dd": kill_line_to_clipboard'

###############################################################################
#
# Autocompletion
#
###############################################################################

# Bash

# enable extended pattern matching
shopt -s extglob

# Globstar: The pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
# To unset use:
# shopt -u globstar
shopt -s globstar
# This script prevents wildcard (*) expansion, don't use
#source /etc/profile.d/bash_completion.sh

# If there are multiple matches for completion, Tab should cycle through them
# Disabled because to see the results you'll always select the first entry on tab
#bind 'TAB: menu-complete'
bind '"\C-j": menu-complete'

# And Shift-Tab should cycle backwards
#bind '"\e[Z": menu-complete-backward'
bind '"\C-k": menu-complete-backward'

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


###############################################################################
#
# Aliases
#
###############################################################################
# Custom Scripts
alias fzgrep='~/.scripts/fzgrep.sh'

# Get remote ip address
alias ipv4lookup='dig +short myip.opendns.com @resolver1.opendns.com'
alias ipv6lookup='ip -6 addr'

# Neovim
alias nvim='~/Applications/nvim.appimage'


###############################################################################
#
# Environment Variables
#
###############################################################################
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
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
