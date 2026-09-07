# Check ./profile-env-private.sh for $EDITOR variable

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

#################################
#
# General Config
#
#################################

source ~/.terminal/profile-general.sh

#################################
#
# Aliases
#
#################################

source ~/.terminal/profile-aliases-public.sh
[ -f ~/.terminal/profile-aliases-private.sh ] && source ~/.terminal/profile-aliases-private.sh

#################################
#
# Autocompletion
#
#################################

source ~/.terminal/profile-autocompletion.sh

#################################
#
# Environment Variables
#
#################################

source ~/.terminal/profile-env-public.sh
[ -f ~/.terminal/profile-env-private.sh ] && source ~/.terminal/profile-env-private.sh

#################################
#
# Environment Keymappings
#
#################################

source ~/.terminal/profile-virtualterminal-keymappings.sh

#################################
#
# OS Specific Configs
#
#################################

if [ "$(uname)" == "Darwin" ]; then
    source ~/.terminal/profile-path-public.mac.sh
elif [ "$(uname)" == "Linux" ]; then
    source ~/.terminal/profile-path-public.linux.sh
fi

# machine-specific config (untracked, never merged): ~/.profile.local
[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"

