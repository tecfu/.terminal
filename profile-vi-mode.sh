#################################
#
# Vi Mode Related
#
#################################

# Set vimode, Vim as editor
set -o vi

# Macros to enable yanking, killing and putting to and from the system clipboard in vi-mode. Only supports yanking and killing the whole line.
# see: https://unix.stackexchange.com/a/595798/146921
paste_from_clipboard () {
  local shift=$1

  local head=${READLINE_LINE:0:READLINE_POINT+shift}
  local tail=${READLINE_LINE:READLINE_POINT+shift}

  local paste=$(xclip -out -selection clipboard)
  local paste_len=${#paste}

  READLINE_LINE=${head}${paste}${tail}
  # Place caret before last char of paste (as in vi)
  let READLINE_POINT+=$paste_len+$shift-1
}

yank_line_to_clipboard () {
  echo $READLINE_LINE | xclip -in -selection clipboard
}

kill_line_to_clipboard () {
  yank_line_to_clipboard
  READLINE_LINE=""
}

bind -m vi-command -x '"P": paste_from_clipboard 0'
bind -m vi-command -x '"p": paste_from_clipboard 1'
bind -m vi-command -x '"yy": yank_line_to_clipboard'
bind -m vi-command -x '"dd": kill_line_to_clipboard'
