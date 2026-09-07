# zsh config — plain zsh, no framework.
# (The oh-my-zsh template was removed: omz was never installed and sourcing
# it errored on every zsh start; the Zinit auto-clone chunk went with it.)

# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# vi mode
bindkey -v
bindkey -rM vicmd '\040' # unbind space using octal value
bindkey -M vicmd '\040\141' beginning-of-line #works
bindkey -M vicmd '\040\073' end-of-line #works

# completion (from compinstall)
bindkey '^[[Z' reverse-menu-complete
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
autoload -Uz compinit
compinit

# prompt: user@host, path, git branch — builtin vcs_info
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' (%b)'
precmd() { vcs_info }
setopt prompt_subst
PS1='%F{blue}%B%n@%m%b%f %F{yellow}%~%f${vcs_info_msg_0_}
%F{green}%#%f '

# machine-specific config (untracked, never merged): ~/.zshrc.local
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
