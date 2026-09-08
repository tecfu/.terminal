# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# ---- prompt theme 'plain' (default): plain bash + git's own git-sh-prompt (no framework) ----
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

# 'plain' (default) is the builder above.
# ---- prompt theme: powerline-multiline (from oh-my-bash) ----
shopt -s checkwinsize  # refresh COLUMNS after each command so the prompt tracks resizes
printf -v _PML_SEP_L '\ue0b0'; printf -v _PML_SEP_R '\ue0b2'  # powerline arrows
# Line 1: [venv][git][cwd] ...right-aligned... [clock][battery][user]
# Line 2: failed-status (red) + prompt char
# Responsive to the window width: right segments are shed in build order
# (clock, then battery, then user) and the cwd keeps only its tail when tight.
# Selected via PROMPT_THEME=powerline-multiline (see bottom of file);
# powerline-multiline-host reuses this builder with hostname-derived colors.
_pml_lseg() {  # <fg-color> <bg-color> <text> -> appends a left block to $left ($last = prev bg);
               # colors are "5;N" (256-palette) or "2;R;G;B" (truecolor)
  if [ -n "$last" ]; then
    left+="\001\e[0;38;${last};48;${2}m\002${_PML_SEP_L}"
  fi
  left+="\001\e[38;${1};48;${2}m\002 $3 \001\e[0m\002"
  llen=$((llen + ${#3} + 3))  # visible width: arrow + " text "
  last=$2
}
_pml_rseg() {  # <fg-color> <bg-color> <text> -> queues a right block in $rf/$rb/$rt;
               # rendered after all blocks exist so narrow windows can shed some
  rf+=("$1"); rb+=("$2"); rt+=("$3")
  rlen=$((rlen + ${#3} + 3))
}
# colors from the original theme: scm clean 25 / dirty 88 / staged 30 / unstaged 92,
# venv 35, cwd+clock 240, battery 70/208/160, user 32, last status 196
__ps1_build_pml() {
  local s=$? left="" last="" right="" rlast="" rlen=0 llen=0 b st d cap="" ac="" bc staged unstaged
  local rf=() rb=() rt=() cols="${COLUMNS:-80}" cwd maxcwd drop i
  local f="${_PML_HOST_FG:-39}" cbg="${_PML_HOST_BG:-}"
  local c_venv="${cbg:-5;35}" c_cwd="${cbg:-5;240}" c_clock="${cbg:-5;240}" c_user="${cbg:-5;32}"

  if [ -n "${CONDA_DEFAULT_ENV:-}" ]; then
    _pml_lseg "$f" "$c_venv" "❲c❳ $CONDA_DEFAULT_ENV"
  elif [ -n "${VIRTUAL_ENV:-}" ]; then
    _pml_lseg "$f" "$c_venv" "❲p❳ ${VIRTUAL_ENV##*/}"
  fi

  if b=$(git symbolic-ref --short -q HEAD 2>/dev/null) || b=$(git rev-parse --short HEAD 2>/dev/null); then
    staged=0 unstaged=0
    read -r staged unstaged < <(
      git status --porcelain 2>/dev/null | awk '{x=substr($0,1,1);y=substr($0,2,1);
        if(x!=" "&&x!="?")st=1; if(y!=" ")un=1} END{print (st?st:0)+0,(un?un:0)+0}')
    bc=25
    [ "$staged" = 1 ] && [ "$unstaged" = 1 ] && bc=88
    [ "$staged" = 1 ] && [ "$unstaged" = 0 ] && bc=30
    [ "$staged" = 0 ] && [ "$unstaged" = 1 ] && bc=92
    if [ -n "$cbg" ]; then
      case $bc in 25) bc=117 ;; 88) bc=203 ;; 30) bc=80 ;; 92) bc=141 ;; esac
      _pml_lseg "5;$bc" "$cbg" " $b"
    else
      _pml_lseg 39 "5;$bc" " $b"
    fi
  fi

  cwd="${PWD/#$HOME/\~}"
  maxcwd=$(( cols - 4 - llen ))  # room left after venv/git segments + closing arrow
  if (( ${#cwd} > maxcwd && maxcwd > 1 )); then
    cwd="…${cwd: -$((maxcwd - 1))}"  # keep the tail; -1 makes room for the ellipsis
  fi
  _pml_lseg "$f" "$c_cwd" "$cwd"
  left+="\001\e[0;38;${last}m\002${_PML_SEP_L}\001\e[0m\002"

  _pml_rseg "$f" "$c_clock" "$(date +"${THEME_CLOCK_FORMAT:-%H:%M:%S}")"
  for d in /sys/class/power_supply/BAT*; do
    [ -f "$d/capacity" ] || continue
    cap=$(<"$d/capacity"); st=$(<"$d/status")
    [ "$st" = Discharging ] || ac="⚡"
    break
  done
  if [ -n "$cap" ]; then
    bc=70; [ "$cap" -le 25 ] && bc=208; [ "$cap" -le 5 ] && bc=160
    if [ -n "$cbg" ]; then
      [ "$bc" = 70 ] && bc=114
      _pml_rseg "5;$bc" "$cbg" "$ac$cap%"
    else
      _pml_rseg 39 "5;$bc" "$ac$cap%"
    fi
  fi
  if [ -n "${SSH_CLIENT:-}" ]; then
    _pml_rseg "$f" "$c_user" " $USER@${HOSTNAME%%.*}"
  else
    _pml_rseg "$f" "$c_user" "$USER"
  fi

  # responsive: shed right segments in build order (clock, then battery, then
  # user) until left + right fits, then render the survivors (first survivor
  # gets the cap arrow)
  drop=0
  while (( drop < ${#rt[@]} && llen + rlen > cols - 1 )); do
    (( rlen -= ${#rt[drop]} + 3 ))
    (( drop++ ))
  done
  for (( i=drop; i<${#rt[@]}; i++ )); do
    if [ -n "$rlast" ]; then
      right+="\001\e[0;38;${rb[i]};48;${rlast}m\002${_PML_SEP_R}"
    else
      right+="\001\e[0;38;${rb[i]}m\002${_PML_SEP_R}"
    fi
    right+="\001\e[38;${rf[i]};48;${rb[i]}m\002 ${rt[i]} \001\e[0m\002"
    rlast=${rb[i]}
  done

  bc=""
  [ "$s" -ne 0 ] && bc="\001\e[0;38;5;196m\002 $s \001\e[0m\002"
  PS1="$left\001\e[999C\002\001\e[${rlen}D\002$right\n${bc}❯ "
}

# ---- prompt theme: powerline-multiline-host ----
# Darkreader effect, unique per machine: a hash of the hostname picks a hue;
# the statusbar becomes a medium-dark tint of that hue and the text a light,
# desaturated version of the same hue (so text is always readable). Git and
# battery state colors move from block background to light text colors.
# Needs a truecolor (24-bit) terminal.
__ps1_host_colors() {
  local seed fr fg2 fb br bg2 bb
  seed=$(cksum <<< "${HOSTNAME:-localhost}"); seed=${seed%% *}
  read -r fr fg2 fb br bg2 bb < <(awk -v seed="$seed" '
    function hsv(h, s, v,  c, x, m, xx) {
      c = v*s; xx = (h/60)%2-1; if (xx < 0) xx = -xx; x = c*(1-xx); m = v-c
      if (h<60)       { cr=c; cg=x; cb=0 }
      else if (h<120) { cr=x; cg=c; cb=0 }
      else if (h<180) { cr=0; cg=c; cb=x }
      else if (h<240) { cr=0; cg=x; cb=c }
      else if (h<300) { cr=x; cg=0; cb=c }
      else            { cr=c; cg=0; cb=x }
      cr = int((cr+m)*255+.5); cg = int((cg+m)*255+.5); cb = int((cb+m)*255+.5)
    }
    BEGIN {
      hue = seed % 360
      # statusbar: medium-dark tint of the machine hue (jittered per host)
      hsv(hue, .45 + (int(seed/35) % 3) * .05, .22 + (int(seed/35) % 4) * .02)
      br = cr; bg2 = cg; bb = cb
      # text: light, desaturated version of the same hue; luminance-boosted
      # until clearly readable on the dark tint
      s = .35 + (int(seed/7) % 3) * .05
      v = .72 + (seed % 4) * .04
      hsv(hue, s, v)
      while ((0.299*cr + 0.587*cg + 0.114*cb) < 165 && (v < 1 || s > .15)) {
        if (v < 1) v += 0.04; else s -= 0.05
        hsv(hue, s, v)
      }
      fr = cr; fg2 = cg; fb = cb
      printf "%d %d %d %d %d %d", fr, fg2, fb, br, bg2, bb
    }')
  _PML_HOST_FG="2;$fr;$fg2;$fb"
  _PML_HOST_BG="2;$br;$bg2;$bb"
}

# ---- tools formerly provided by oh-my-bash plugins ----
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
[ -f "$HOME/.terminal/bashmarks.sh" ] && . "$HOME/.terminal/bashmarks.sh"

# keep world-writable (ow) dirs from getting a loud background color in ls
LS_COLORS="$LS_COLORS:ow=103;30;01"

# machine-specific config (untracked, never merged): ~/.bashrc.local
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"

# prompt theme: 'plain' (default), 'powerline-multiline', or
# 'powerline-multiline-host' (hostname-hash colored statusbar)
case ${PROMPT_THEME:-} in
  powerline-multiline) PROMPT_COMMAND=__ps1_build_pml ;;
  powerline-multiline-host)
    PROMPT_COMMAND=__ps1_build_pml
    __ps1_host_colors ;;
esac
