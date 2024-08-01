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
