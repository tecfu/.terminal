#################################
#
# Environment Variables
#
#################################

# prevent oh-my-bash from paging git results
export GIT_PAGER=""

# Ignore commands leading with a space in terminal history
# https://stackoverflow.com/a/29188490/3751385
export HISTCONTROL=ignoreboth

export EDITOR='nvim'
export VISUAL='nvim'

# pi (coding agent): force OSC 8 hyperlink rendering. Alacritty exports TERM=alacritty
# but not TERM_PROGRAM, so pi's terminal detection falls through to "unknown" and
# prints URLs as plain text. Alacritty itself supports OSC 8 (Ctrl+click to open).
export PI_HYPERLINKS=1

# pi/MCP auth on headless ssh hosts: pi opens auth URLs via xdg-open, which has no
# browser there. BROWSER routes them through the ssh RemoteForward tunnel (port
# 15147) to remote-url-opener on the desktop. Falls back to xdg-open when the
# tunnel is down, so local/Graphical sessions are unaffected.
export BROWSER="$HOME/.terminal/scripts/pi-open.sh %s"

# Add user's private bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# For Golang
export PATH="$HOME/go/bin:$PATH"

# For Rust package manager, Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# For Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
