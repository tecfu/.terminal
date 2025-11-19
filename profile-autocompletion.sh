#################################
#
# Autocompletion
#
#################################

# Enable extended pattern matching
shopt -s extglob

# Show all matches if ambiguous
bind 'set show-all-if-ambiguous on'

# Perform partial completion on the first Tab press
bind 'set menu-complete-display-prefix on'

# Revert to a more classic tab-completion behavior
# bind 'set show-all-if-ambiguous on'

# Source git completion if available
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

# Terraform completion
complete -C /usr/bin/terraform terraform

# Linux specific configuration
if [ "$(uname)" = "Linux" ]; then
  # Linux specific configuration
  # Add your Linux-specific configuration commands here
  # Enable recursive globbing
  shopt -s globstar

  # Bind Tab to menu-complete
  bind 'TAB: menu-complete'
  bind '"\e[Z": menu-complete-backward'
fi


## FZF Autocompletion Setup

# Custom fzf options (place these BEFORE the fzf source line)
# export FZF_DEFAULT_OPTS="--bind 'ctrl-j:down,ctrl-k:up'"

# Source fzf if available
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# --- Definitive fzf Smart Tab Completion ---
#
# This function is designed to be highly robust. It handles the Tab key
# with two behaviors:
# 1. On an empty line, it launches fzf for file selection.
# 2. On a non-empty line, it uses standard bash-completion.
#
# It first tries to use the official _fzf_complete function. If that fails
# (due to shell scope issues), it falls back to calling fzf directly.
#
_fzf_definitive_tab() {
    # Check if the command line is empty.
    if [[ -z "$COMP_LINE" ]]; then
        # Try to use the officially loaded fzf completion function first.
        if declare -f _fzf_complete > /dev/null; then
            _fzf_complete
        else
            # As a robust fallback, call the fzf program directly.
            # This works even if the helper functions are not in scope.
            COMPREPLY=($(fzf --height 40% --border --reverse))
        fi
        return 0
    fi

    # If the line is NOT empty, use the standard bash-completion handler.
    # We check if the _command function exists to be safe.
    if declare -f _command > /dev/null; then
        _command
    fi
}

# Tell Bash to use our new function as the default completion handler.
complete -D -F _fzf_definitive_tab
# --- End of Definitive fzf Completion ---

## npm autocompletion
## depends on: `npm completion > ~/.npm-completion.sh`
source ~/.npm-completion.sh
