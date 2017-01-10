# Initially based on
# https://github.com/joshuaclayton/dotfiles/blob/master/zsh_profile.d/autoenv.zsh

# File to store confirmed authentication into.
# This handles the deprecated, old location(s).
if [[ -z $AUTOENV_AUTH_FILE ]]; then
  if [[ -n $AUTOENV_ENV_FILENAME ]]; then
    echo "zsh-autoenv: using deprecated setting for AUTOENV_AUTH_FILE from AUTOENV_ENV_FILENAME." >&2
    echo "Please set AUTOENV_AUTH_FILE instead." >&2
    AUTOENV_AUTH_FILE=$AUTOENV_ENV_FILENAME
  else
    if [[ -n $XDG_DATA_HOME ]]; then
      AUTOENV_AUTH_FILE=$XDG_DATA_HOME/autoenv_auth
    else
      AUTOENV_AUTH_FILE=~/.local/share/autoenv_auth
    fi
    if [[ -f ~/.env_auth ]]; then
      echo "zsh-autoenv: using deprecated location for AUTOENV_AUTH_FILE." >&2
      echo "Please move it: mv ~/.env_auth ${(D)AUTOENV_AUTH_FILE}" >&2
      AUTOENV_AUTH_FILE=~/.env_auth
    fi
  fi
fi

# Name of the file to look for when entering directories.
: ${AUTOENV_FILE_ENTER:=.autoenv.zsh}

# Name of the file to look for when leaving directories.
# Requires AUTOENV_HANDLE_LEAVE=1.
: ${AUTOENV_FILE_LEAVE:=.autoenv_leave.zsh}

# Look for zsh-autoenv "enter" files in parent dirs?
: ${AUTOENV_LOOK_UPWARDS:=1}

# Handle leave events when changing away from a subtree, where an "enter"
# event was handled?
: ${AUTOENV_HANDLE_LEAVE:=1}

# Enable debugging. Multiple levels are supported (max 2).
: ${AUTOENV_DEBUG:=0}

# (Temporarily) disable zsh-autoenv. This gets looked at in the chpwd handler.
: ${AUTOENV_DISABLED:=0}

# Public helper functions, which can be used from your .autoenv.zsh files:
#
# Source the next .autoenv.zsh file from parent directories.
# This is useful if you want to use a base .autoenv.zsh file for a directory
# subtree.
autoenv_source_parent() {
  local look_until=${1:-/}
  local parent_env_file=$(_autoenv_get_file_upwards \
    ${autoenv_env_file:h} ${AUTOENV_FILE_ENTER} $look_until)

  if [[ -n $parent_env_file ]] \
    && _autoenv_check_authorized_env_file $parent_env_file; then
    _autoenv_debug "Calling autoenv_source_parent: parent_env_file:$parent_env_file"
    _autoenv_source $parent_env_file enter
  fi
}

# Internal functions. {{{
# Internal: stack of entered (and handled) directories. {{{
typeset -g -a _autoenv_stack_entered
# -g: make it global, this is required when used with antigen.
typeset -g -A _autoenv_stack_entered_mtime

# Add an entry to the stack, and remember its mtime.
_autoenv_stack_entered_add() {
  local env_file=$1

  # Remove any existing entry.
  _autoenv_stack_entered_remove $env_file

  _autoenv_debug "[stack] adding: $env_file" 2

  # Append it to the stack, and remember its mtime.
  _autoenv_stack_entered+=($env_file)
  _autoenv_stack_entered_mtime[$env_file]=$(_autoenv_get_file_mtime $env_file)
}


# zstat_mime helper, conditionally defined.
# Load zstat module, but only its builtin `zstat`.
if ! zmodload -F zsh/stat b:zstat 2>/dev/null; then
  # If the module is not available, define a wrapper around `stat`, and use its
  # terse output instead of format, which is not supported by busybox.
  # Assume '+mtime' as $1.
  _autoenv_get_file_mtime() {
    # setopt localoptions pipefail
    local stat
    stat=$(stat -t $1 2>/dev/null)
    if [[ -n $stat ]]; then
      echo ${${(s: :)stat}[13]}
    else
      echo 0
    fi
  }
else
  _autoenv_get_file_mtime() {
    zstat +mtime $1 2>/dev/null || echo 0
  }
fi


# Remove an entry from the stack.
_autoenv_stack_entered_remove() {
  local env_file=$1
  _autoenv_debug "[stack] removing: $env_file" 2
  _autoenv_stack_entered[$_autoenv_stack_entered[(i)$env_file]]=()
  _autoenv_stack_entered_mtime[$env_file]=
}

# Is the given entry already in the stack?
# This checks for the env_file ($1) as-is and with symlinks resolved.
_autoenv_stack_entered_contains() {
  local env_file=$1
  local f i
  if (( ${+_autoenv_stack_entered[(r)${env_file}]} )); then
    # Entry is in stack.
    f=$env_file
  else
    for i in $_autoenv_stack_entered; do
      if [[ ${i:A} == ${env_file:A} ]]; then
        # Entry is in stack (compared with resolved symlinks).
        f=$i
        break
      fi
    done
  fi
  if [[ -n $f ]]; then
    if [[ $_autoenv_stack_entered_mtime[$f] == $(_autoenv_get_file_mtime $f) ]]; then
      # Entry has the expected mtime.
      return
    fi
  fi
  return 1
}
# }}}

# Internal function for debug output. {{{
_autoenv_debug() {
  local msg="$1"  # Might trigger a bug in Zsh 5.0.5 with shwordsplit.
  local level=${2:-1}
  if [[ $AUTOENV_DEBUG -lt $level ]]; then
    return
  fi
  # Load zsh color support.
  if [[ -z $color ]]; then
    autoload colors
    colors
  fi
  # Build $indent prefix.
  local indent=
  if [[ $_autoenv_debug_indent -gt 0 ]]; then
    for i in {1..${_autoenv_debug_indent}}; do
      indent="  $indent"
    done
  fi

  # Split $msg by \n (not newline).
  lines=(${(ps:\\n:)msg})
  for line in $lines; do
    echo -n "${fg_bold[blue]}[autoenv]${fg_no_bold[default]} " >&2
    echo ${indent}${line} >&2
  done
}
# }}}


# Generate hash pair for a given file ($1) and version ($2).
# A fixed hash value can be given as 3rd arg, but is used with tests only.
# The format is ":$file:$hash:$version".
_autoenv_hash_pair() {
  local env_file=${1:A}
  local cksum_version=${2:-2}
  local env_cksum=${3:-}
  if [[ -z $env_cksum ]]; then
    if ! [[ -e $env_file ]]; then
      echo "Missing file argument for _autoenv_hash_pair!" >&2
      return 1
    fi
    if [ $cksum_version = 2 ]; then
      # Get the output from `cksum` and join the first two words with a dot.
      env_cksum=${(j:.:)${:-$(cksum "$env_file")}[1,2]}
    elif [ $cksum_version = 1 ]; then
      env_cksum=$(shasum $env_file | cut -d' ' -f1)
    else
      echo "Invalid version argument (${cksum_version}) for _autoenv_hash_pair!" >&2
      return 1
    fi
  fi
  echo ":${env_file}:${env_cksum}:${cksum_version}"
}


# Checks for the existence of a hash signature in the auth file
_autoenv_authorized_pair() {
  local pair=$1
  test -f $AUTOENV_AUTH_FILE \
    && \grep -qF $pair $AUTOENV_AUTH_FILE
}


_autoenv_authorized_env_file() {
  local env_file=$1
  local pair
  pair=$(_autoenv_hash_pair $env_file)
  _autoenv_debug "v2 pair: ${pair}"
  if ! _autoenv_authorized_pair $pair; then
    # Fallback for v1 (SHA-1) pairs
    pair=$(_autoenv_hash_pair $env_file 1)
    _autoenv_debug "v1 pair: ${pair}"
    if _autoenv_authorized_pair $pair; then
      # Upgrade v1 entries to v2
      _autoenv_authorize $env_file
    else
      return 1
    fi
  fi
}

_autoenv_authorize() {
  local env_file=${1:A}
  _autoenv_deauthorize $env_file
  [[ -d ${AUTOENV_AUTH_FILE:h} ]] || mkdir -p ${AUTOENV_AUTH_FILE:h}
  _autoenv_hash_pair $env_file >>| $AUTOENV_AUTH_FILE
}

# Deauthorize a given filename, by removing it from the auth file.
# This uses `test -s` to only handle non-empty files.
_autoenv_deauthorize() {
  local env_file=${1:A}
  if [[ -s $AUTOENV_AUTH_FILE ]]; then
    \grep -vF :${env_file}: $AUTOENV_AUTH_FILE >| $AUTOENV_AUTH_FILE.tmp
    \mv $AUTOENV_AUTH_FILE.tmp $AUTOENV_AUTH_FILE
  fi
}

# This function can be mocked in tests
_autoenv_ask_for_yes() {
  local answer

  # Handle/catch Ctrl-C and return, instead of letting it potentially abort the
  # shell setup process.
  setopt localtraps
  trap 'return 1' INT

  read answer
  if [[ $answer == "yes" ]]; then
    return 0
  else
    return 1
  fi
}

# Args: 1: absolute path to env file (resolved symlinks).
_autoenv_check_authorized_env_file() {
  if ! [[ -f $1 ]]; then
    return 1
  fi
  if ! _autoenv_authorized_env_file $1; then
    echo "Attempting to load unauthorized env file!" >&2
    command ls -l $1 >&2
    echo >&2
    echo "**********************************************" >&2
    echo >&2
    command cat $1 >&2
    echo >&2
    echo "**********************************************" >&2
    echo >&2
    echo -n "Would you like to authorize it? (type 'yes') " >&2
    # echo "Would you like to authorize it?"
    # echo "('yes' to allow, 'no' to not being asked again; otherwise ignore it for the shell) "

    if ! _autoenv_ask_for_yes; then
      return 1
    fi

    _autoenv_authorize $1
  fi
  return 0
}

_autoenv_source() {
  # Public API for the .autoenv.zsh script.
  local autoenv_env_file=$1
  local autoenv_event=$2
  local autoenv_from_dir=$OLDPWD
  local autoenv_to_dir=$PWD

  # Source varstash library once.
  # XXX: pollutes environment with e.g. `stash`, and `autostash` will cause
  # an overwritten `stash` function to be called!
  if [[ -z "$functions[(I)autostash]" ]]; then
    if \grep -qE '\b(autostash|autounstash|stash)\b' $autoenv_env_file; then
      source ${${funcsourcetrace[1]%:*}:h}/lib/varstash
    fi
    # NOTE: Varstash uses $PWD as default for varstash_dir, we might set it to
    # ${autoenv_env_file:h}.
  fi

  # Source the env file.
  _autoenv_debug "== SOURCE: ${bold_color:-}$autoenv_env_file${reset_color:-}\n      PWD: $PWD"
  : $(( _autoenv_debug_indent++ ))
  source $autoenv_env_file
  : $(( _autoenv_debug_indent-- ))
  _autoenv_debug "== END SOURCE =="

  if [[ $autoenv_event == enter ]]; then
    _autoenv_stack_entered_add $autoenv_env_file
  fi
}

_autoenv_get_file_upwards() {
  local look_from=${1:-$PWD}
  local look_for=${2:-$AUTOENV_FILE_ENTER}
  local look_until=${${3:-/}:A}

  # Manually look in parent dirs. An extended Zsh glob should use Y1 for
  # performance reasons, which is only available in zsh-5.0.5-146-g9381bb6.
  local last
  local parent_dir="$look_from/.."
  while true; do
    parent_dir=${parent_dir:A}
    if [[ $parent_dir == $last ]]; then
      break
    fi
    local parent_file="${parent_dir}/${look_for}"

    if [[ -f $parent_file ]]; then
      echo $parent_file
      break
    fi

    if [[ $parent_dir == $look_until ]]; then
      break
    fi
    last=$parent_dir
    parent_dir="${parent_dir}/.."
  done
}


_autoenv_chpwd_handler() {
  _autoenv_debug "Calling chpwd handler: PWD=$PWD"

  if (( $AUTOENV_DISABLED )); then
    _autoenv_debug "Disabled (AUTOENV_DISABLED)."
    return
  fi

  local env_file="$PWD/$AUTOENV_FILE_ENTER"
  _autoenv_debug "env_file: $env_file"

  # Handle leave event for previously sourced env files.
  if [[ $AUTOENV_HANDLE_LEAVE == 1 ]] && (( $#_autoenv_stack_entered )); then
    local prev_file prev_dir
    for prev_file in ${_autoenv_stack_entered}; do
      prev_dir=${prev_file:h}
      if ! [[ ${PWD}/ == ${prev_dir}/* ]]; then
        local env_file_leave=$prev_dir/$AUTOENV_FILE_LEAVE
        if _autoenv_check_authorized_env_file $env_file_leave; then
          _autoenv_source $env_file_leave leave $prev_dir
        fi

        # Unstash any autostashed stuff.
        if [[ -n "$functions[(I)autostash]" ]]; then
          varstash_dir=$prev_dir autounstash
        fi

        _autoenv_stack_entered_remove $prev_file
      fi
    done
  fi

  if ! [[ -f $env_file ]] && [[ $AUTOENV_LOOK_UPWARDS == 1 ]]; then
    env_file=$(_autoenv_get_file_upwards $PWD)
    if [[ -z $env_file ]]; then
      return
    fi
  fi

  # Load the env file only once: check if $env_file is in the stack of entered
  # directories.
  if _autoenv_stack_entered_contains $env_file; then
    _autoenv_debug "Already in stack: $env_file"
    return
  fi

  if ! _autoenv_check_authorized_env_file $env_file; then
    return
  fi

  # Source the enter env file.
  _autoenv_debug "Sourcing from chpwd handler: $env_file"
  _autoenv_source $env_file enter

  : $(( _autoenv_debug_indent++ ))
}
# }}}

autoload -U add-zsh-hook
add-zsh-hook chpwd _autoenv_chpwd_handler

# Look in current directory already.
_autoenv_chpwd_handler
