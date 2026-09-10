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

# System bash-completion: registers per-command completions (ssh, cargo, ...).
# Docker gets registered eagerly: bash-completion >= 2.12 loads lazily via its
# own -D handler, which the fzf tab handler below overwrites.
[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
command -v docker >/dev/null && eval "$(docker completion bash 2>/dev/null)"

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
    # bash-completion >= 2.12 renamed _command to _comp_command.
    if declare -F _command >/dev/null; then
        _command
    elif declare -F _comp_command >/dev/null; then
        _comp_command
    fi
}

# Tell Bash to use our new function as the default completion handler.
# -o default: fall back to readline filename completion when the handler
# produces nothing (e.g. bash-completion not loaded -> _command undefined).
complete -D -F _fzf_definitive_tab -o default -o filenames
# --- End of Definitive fzf Completion ---

## npm autocompletion
## depends on: `npm completion > ~/.npm-completion.sh`
[ -f ~/.npm-completion.sh ] && source ~/.npm-completion.sh
