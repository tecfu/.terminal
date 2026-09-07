# bashmarks — directory bookmarks: bm -a/-g/-p/-d/-l (aliases: s g p d)
# Vendored from oh-my-bash plugins/bashmarks (omb util calls stripped).
# Upstream: https://github.com/huyng/bashmarks
# commit 264952f2225691b5f99a498e4834e2c69bf4f5f5
#
# Copyright (c) 2010, Huy Nguyen, https://everyhue.me
# Copyright (c) 2015, Toan Nguyen, https://nntoan.github.io
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors may be
#       used to endorse or promote products derived from this software without
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#------------------------------------------------------------------------------

# USAGE:
# bm -a bookmarkname - saves the curr dir as bookmarkname
# bm -g bookmarkname - jumps to the that bookmark
# bm -g b[TAB] - tab completion is available
# bm -p bookmarkname - prints the bookmark
# bm -p b[TAB] - tab completion is available
# bm -d bookmarkname - deletes the bookmark
# bm -d [TAB] - tab completion is available
# bm -l - list all bookmarks

# Default configurations
if [[ ! ${BASHMARKS_SDIRS-} ]]; then
  BASHMARKS_SDIRS=${SDIRS:-$HOME/.sdirs}
fi

# setup file to store bookmarks
if [[ ! -e $BASHMARKS_SDIRS ]]; then
  touch "$BASHMARKS_SDIRS"
fi

# main function
function bm {
  local option=$1
  case $option in
    # save current directory to bookmarks [ bm -a BOOKMARK_NAME ]
    -a)
      _bashmarks_save "$2"
    ;;
    # delete bookmark [ bm -d BOOKMARK_NAME ]
    -d)
      _bashmarks_delete "$2"
    ;;
    # jump to bookmark [ bm -g BOOKMARK_NAME ]
    -g)
      _bashmarks_goto "$2"
    ;;
    # print bookmark [ bm -p BOOKMARK_NAME ]
    -p)
      _bashmarks_print "$2"
    ;;
    # show bookmark list [ bm -l ]
    -l)
      _bashmarks_list
    ;;
    # help [ bm -h ]
    -h)
      _bashmarks_usage
    ;;
    *)
      if [[ $1 == -* ]]; then
        # unrecognized option. echo error message and usage [ bm -X ]
        printf '%s\n' "Unknown option '$1'"
        _bashmarks_usage
        kill -SIGINT $$
        exit 1
      elif [[ $1 == "" ]]; then
        # no args supplied - echo usage [ bm ]
        _bashmarks_usage
      else
        # non-option supplied as first arg.  assume goto [ bm BOOKMARK_NAME ]
        _bashmarks_goto "$1"
      fi
    ;;
  esac
}

# print usage information
function _bashmarks_usage {
  printf '%s\n' 'USAGE:'
  printf '%s\n' "bm -h                   - Prints this usage info"
  printf '%s\n' 'bm -a <bookmark_name>   - Saves the current directory as "bookmark_name"'
  printf '%s\n' 'bm [-g] <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
  printf '%s\n' 'bm -p <bookmark_name>   - Prints the directory associated with "bookmark_name"'
  printf '%s\n' 'bm -d <bookmark_name>   - Deletes the bookmark'
  printf '%s\n' 'bm -l                   - Lists all available bookmarks'
}

# save current directory to bookmarks
function _bashmarks_save {
  if _bashmarks_is_valid_bookmark_name "$@"; then
    _bashmarks_purge_line "$BASHMARKS_SDIRS" "export DIR_$1="
    CURDIR=$(sed "s#^$HOME#\$HOME#g" <<< "$PWD")
    printf '%s\n' "export DIR_$1=\"$CURDIR\"" >> "$BASHMARKS_SDIRS"
  fi
}

# delete bookmark
function _bashmarks_delete {
  if _bashmarks_is_valid_bookmark_name "$@"; then
    _bashmarks_purge_line "$BASHMARKS_SDIRS" "export DIR_$1="
    unset "DIR_$1"
  fi
}

# jump to bookmark
function _bashmarks_goto {
  source "$BASHMARKS_SDIRS"
  local target_varname=DIR_$1
  local target=${!target_varname-}
  if [[ -d $target ]]; then
    cd "$target"
  elif [[ ! $target ]]; then
    printf "\033[0;33mWARNING: '%s' bashmark does not exist\033[0m\n" "$1"
  else
    printf "\033[0;33mWARNING: '%s' does not exist\033[0m\n" "$target"
  fi
}

# list bookmarks with dirname
function _bashmarks_list {
  source "$BASHMARKS_SDIRS"
  # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
  env | sort | awk '/^DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
  # uncomment this line if color output is not working with the line above
  # env | grep "^DIR_" | cut -c5- | sort |grep "^.*="
}

# print bookmark
function _bashmarks_print {
  source "$BASHMARKS_SDIRS"
  local var=DIR_$1
  printf '%s\n' "${!var}"
}

# list bookmarks without dirname
function _bashmarks_list_names {
  source "$BASHMARKS_SDIRS"
  env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "="
}

# validate bookmark name
# @var[out] exit_message
function _bashmarks_is_valid_bookmark_name {
  local exit_message=""
  if [[ ! $1 ]]; then
    exit_message="bookmark name required"
    printf '%s\n' "$exit_message" >&2
    return 1
  elif [[ $1 == *[!A-Za-z0-9_]* ]]; then
    exit_message="bookmark name is not valid"
    printf '%s\n' "$exit_message" >&2
    return 1
  fi
}

# completion command
function _bashmarks_comp_cmd_bm {
  COMPREPLY=()

  # bm, g, p, d, bm -[gpd]
  if ((COMP_CWORD == 1)) || { ((COMP_CWORD >= 2)) && [[ ${COMP_WORDS[1]} == -[gpd] ]]; }; then
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '$(_bashmarks_list_names)' -- "$cur"))
  fi

  return 0
}

# safe delete line from sdirs
function _bashmarks_purge_line {
  if [[ -s $1 ]]; then
    # safely create a temp file.  To atomically rewrite the target file with
    # "mv", we create the temporary file in the same directory as the target of
    # the symbolic link.
    local dest tmpdir t
    dest=$(readlink -f -- "$1" 2>/dev/null)
    [ -n "$dest" ] || dest=$1
    tmpdir=$(dirname -- "$dest")
    t=$(mktemp "${tmpdir%/}/bashmarks.XXXXXX") || exit 1
    trap "/bin/rm -f -- '$t'" EXIT

    # purge line
    sed "/$2/d" "$1" >| "$t" &&
      /bin/mv -f -- "$t" "$dest"

    # cleanup temp file
    /bin/rm -f -- "$t"
    trap - EXIT
  fi
}

# bind completion command for g,p,d to _bashmarks_comp_cmd_bm
shopt -s progcomp
complete -F _bashmarks_comp_cmd_bm bm
complete -F _bashmarks_comp_cmd_bm g
complete -F _bashmarks_comp_cmd_bm p
complete -F _bashmarks_comp_cmd_bm d

alias s='bm -a'       # Save a bookmark [bookmark_name]
alias g='bm -g'       # Go to bookmark [bookmark_name]
alias p='bm -p'       # Print bookmark of a path [path]
alias d='bm -d'       # Delete a bookmark [bookmark_name]
