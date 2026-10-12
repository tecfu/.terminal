#################################
#
# General Config
#
#################################
#Allows ctrl-s, ctrl-q in Vim
#stty -ixon > /dev/null 2>/dev/null

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#################################
#
# PATH helpers
#
#################################

# pathmunge <dir> [pre|post] — add <dir> to $PATH at most once.
#
# Use this instead of `export PATH="$dir:$PATH"` in any profile file: those
# files are read twice per login shell (.profile, then again by the loader loop
# in .bashrc) and again by every nested bash, so the bare form duplicates each
# entry every time. Default position is `pre`, so a user/tool install wins over
# the system copy. A directory that does not exist is skipped, so a tool that is
# not installed on this machine leaves no dead PATH entries behind.
pathmunge() {
    local dir="${1%/}" mode="${2:-pre}"
    [ -n "$dir" ] || return 1
    [ -d "$dir" ] || return 0
    case "$mode" in
        pre)
            pathunmunge "$dir"          # move it, if a parent shell listed it later
            PATH="$dir:$PATH"
            ;;
        post)
            case ":$PATH:" in
                *":$dir:"*) return 0 ;;
            esac
            PATH="$PATH:$dir"
            ;;
        *) return 1 ;;
    esac
    export PATH
}

# pathunmunge <dir> / pathstrip <substring> — drop PATH entries again.
# pathstrip is for versioned paths that come and go (asdf shims).
pathunmunge() { _path_filter exact "$1"; }
pathstrip()   { _path_filter substr "$1"; }

# _path_filter <exact|substr> <pattern> — shared loop for the two above.
_path_filter() {
    local entry out="" noglob_saved=0 IFS=:
    # set -f so a glob character in an entry is never expanded by word splitting
    case "$-" in *f*) ;; *) set -f; noglob_saved=1 ;; esac
    for entry in $PATH; do
        case "$1" in
            exact) [ "$entry" = "$2" ] && continue ;;
            substr) case "$entry" in *"$2"*) continue ;; esac ;;
        esac
        out="${out:+$out:}$entry"
    done
    if [ "$noglob_saved" = 1 ]; then set +f; fi
    PATH="$out"
    export PATH
}

# path_dedup — collapse repeats, keeping the first copy of each directory.
# This handles what the guards above cannot see: entries inherited from a parent
# shell (pi, systemd, an ssh session that already sourced these files).
# Called at the end of .profile and after the loader loop in .bashrc.
path_dedup() {
    local entry out="" noglob_saved=0 IFS=:
    case "$-" in *f*) ;; *) set -f; noglob_saved=1 ;; esac
    for entry in $PATH; do
        case ":$out:" in
            *":$entry:"*) ;;
            *) out="${out:+$out:}$entry" ;;
        esac
    done
    if [ "$noglob_saved" = 1 ]; then set +f; fi
    PATH="$out"
    export PATH
}
