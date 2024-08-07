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
# Vi Mode Related
#
#################################

if [[ "$OSTYPE" != "darwin"* ]]; then
    source ~/.terminal/profile-vi-mode.sh
fi

#################################
#
# Aliases
#
#################################

source ~/.terminal/profile-aliases-public.sh
source ~/.terminal/profile-aliases-private.sh

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
source ~/.terminal/profile-env-private.sh

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
fi

