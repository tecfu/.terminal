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

# xdg-open's DE sniffing finds a GNOME session bus even over plain ssh (the
# user's console session owns one) and then hardcodes `gio open`, which fails
# headless and never consults $BROWSER. Declaring a generic DE makes xdg-open
# honor BROWSER. Only set when there is no display, so desktops are untouched.
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    export XDG_CURRENT_DESKTOP="X-Generic"
fi

# Add user's private bin to PATH
pathmunge "$HOME/.local/bin" pre

# For Golang
pathmunge "$HOME/go/bin" pre

# For Rust package manager, Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# For Volta. The prune + guard-unset that has to run even in non-interactive login
# shells lives at the top of .profile/.bashrc (profile-path-safety.sh); this is the
# canonical entry that file expects to survive.
export VOLTA_HOME="$HOME/.volta"
pathmunge "$VOLTA_HOME/bin" pre
