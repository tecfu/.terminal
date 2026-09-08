# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# ── Prompt: starship ─────────────────────────────────────────────────────
# https://starship.rs — a static binary plus one declarative config
# (starship.toml, symlinked to ~/.config/starship.toml by INSTALL.sh). It
# renders the prompt and handles window-width truncation itself. Nothing
# generates or rewrites shell startup files, so upgrades can't clobber user
# edits (the reason we left oh-my-bash). Without the binary you get bash's
# default prompt.
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

# ---- tools formerly provided by oh-my-bash plugins ----
[ -f "$HOME/.terminal/bashmarks.sh" ] && . "$HOME/.terminal/bashmarks.sh"

# keep world-writable (ow) dirs from getting a loud background color in ls
LS_COLORS="$LS_COLORS:ow=103;30;01"

# machine-specific config (untracked, never merged): ~/.bashrc.local
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
