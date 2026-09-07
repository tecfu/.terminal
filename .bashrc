# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# ---- prompt: plain bash + git's own git-sh-prompt (no framework) ----
for _git_prompt in /usr/lib/git-core/git-sh-prompt \
                   /usr/local/share/git-core/git-prompt.sh \
                   /opt/homebrew/share/git-core/git-prompt.sh; do
  [ -f "$_git_prompt" ] && . "$_git_prompt" && break
done
unset _git_prompt
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1

# Prompt builder (runs via PROMPT_COMMAND so $? is still the last command's):
# user@host, path, git branch, failed-command status, battery while discharging.
# \001/\002 delimit non-printing sequences for readline (they work inside $()).
PROMPT_COMMAND=__ps1_build
__ps1_build() {
  local s=$? base out=""
  base="\001\e[1;34m\002\u@\h\001\e[0m\002 \001\e[0;33m\002\w\001\e[0m\002"
  [ "$s" -ne 0 ] && out=" \001\e[0;31m\002✗$s\001\e[0m\002"
  local d cap="" st
  for d in /sys/class/power_supply/BAT*; do
    [ -f "$d/capacity" ] || continue
    cap=$(<"$d/capacity"); st=$(<"$d/status")
    [ "$st" = Discharging ] && break
    cap=""
  done
  if [ -n "$cap" ]; then
    local c=32
    [ "$cap" -lt 40 ] && c=33
    [ "$cap" -lt 20 ] && c=31
    out="$out \001\e[0;${c}m\002⌁$cap%\001\e[0m\002"
  fi
  if declare -F __git_ps1 >/dev/null; then
    __git_ps1 "$base${out}" "\n\001\e[0;32m\002\\\$ \001\e[0m\002" " (%s)"
  else
    PS1="$base${out}\n\001\e[0;32m\002\\\$ \001\e[0m\002"
  fi
}

# ---- tools formerly provided by oh-my-bash plugins ----
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
[ -f "$HOME/.terminal/bashmarks.sh" ] && . "$HOME/.terminal/bashmarks.sh"

# keep world-writable (ow) dirs from getting a loud background color in ls
LS_COLORS="$LS_COLORS:ow=103;30;01"
