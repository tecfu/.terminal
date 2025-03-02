# .bash_profile -*- mode: sh -*-

# Load login settings and environment variables
if [[ -f ~/.profile ]]; then
  source ~/.profile
fi

# Load interactive settings (oh-my-bash)
if [[ -f ~/.bashrc && "${ENV_DISABLE_BASHRC}" != "true" ]]; then
  source ~/.bashrc
fi

