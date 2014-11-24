# Initially based on
# https://github.com/joshuaclayton/dotfiles/blob/master/zsh_profile.d/autoenv.zsh

export AUTOENV_ENV_FILENAME=$HOME/.env_auth

# Name of file to look for when entering directories.
: ${AUTOENV_FILE_ENTER:=.env}

# Name of file to look for when leaving directories.
# Requires AUTOENV_HANDLE_LEAVE=1.
: ${AUTOENV_FILE_LEAVE:=.env.leave}

# Look for .env in parent dirs?
: ${AUTOENV_LOOK_UPWARDS:=1}

# Handle leave events when changing away from a subtree, where an "enter"
# event was handled?
: ${AUTOENV_HANDLE_LEAVE:=1}


# Public helper functions, which can be used from your .env files:
#
# Source the next .env file from parent directories.
# This is useful if you want to use a base .env file for a directory subtree.
autoenv_source_parent() {
  local parent_env_file=$(_autoenv_get_file_upwards $PWD)

  if [[ -n $parent_env_file ]] \
    && _autoenv_check_authorized_env_file $parent_env_file; then

    local parent_env_dir=${parent_env_file:A:h}

    _autoenv_stack_entered_add $parent_env_file

    _autoenv_source $parent_env_file enter $parent_env_dir
  fi
}


# Internal: stack of entered (and handled) directories. {{{
_autoenv_stack_entered=()
typeset -A _autoenv_stack_entered_mtime
_autoenv_stack_entered_mtime=()

# Add an entry to the stack, and remember its mtime.
_autoenv_stack_entered_add() {
  local env_file=$1

  # Remove any existing entry.
  _autoenv_stack_entered_remove $env_file

  # Append it to the stack, and remember its mtime.
  _autoenv_stack_entered+=($env_file)
  _autoenv_stack_entered_mtime[$env_file]=$(_autoenv_get_file_mtime $env_file)
}

_autoenv_get_file_mtime() {
  if [[ -f $1 ]]; then
    zstat +mtime $1
  else
    echo 0
  fi
}

# Remove an entry from the stack.
_autoenv_stack_entered_remove() {
  local env_file=$1
  _autoenv_stack_entered[$_autoenv_stack_entered[(i)$env_file]]=()
  _autoenv_stack_entered_mtime[$env_file]=
}

# Is the given entry already in the stack?
_autoenv_stack_entered_contains() {
  local env_file=$1
  if (( ${+_autoenv_stack_entered[(r)${env_file}]} )); then
    # Entry is in stack.
    if [[ $_autoenv_stack_entered_mtime[$env_file] == $(_autoenv_get_file_mtime $env_file) ]]; then
      # Entry has the expected mtime.
      return
    fi
  fi
  return 1
}
# }}}

# Load zstat module, but only its builtin `zstat`.
zmodload -F zsh/stat b:zstat


_autoenv_hash_pair() {
  local env_file=${1:A}
  if (( $+2 )); then
    env_shasum=$2
  else
    env_shasum=$(shasum $env_file | cut -d' ' -f1)
  fi
  echo "$env_file:$env_shasum:1"
}

_autoenv_authorized_env_file() {
  local env_file=$1
  local pair=$(_autoenv_hash_pair $env_file)
  test -f $AUTOENV_ENV_FILENAME \
    && \grep -qF $pair $AUTOENV_ENV_FILENAME
}

_autoenv_authorize() {
  local env_file=$1
  _autoenv_deauthorize $env_file
  _autoenv_hash_pair $env_file >> $AUTOENV_ENV_FILENAME
}

_autoenv_deauthorize() {
  local env_file=$1
  if [[ -f $AUTOENV_ENV_FILENAME ]]; then
    echo $(\grep -vF $env_file $AUTOENV_ENV_FILENAME) > $AUTOENV_ENV_FILENAME
  fi
}

# This function can be mocked in tests
_autoenv_read_answer() {
  local answer
  read $=_AUTOENV_TEST_READ_ARGS -q answer
  echo $answer
}

# Args: 1: absolute path to env file (resolved symlinks).
_autoenv_check_authorized_env_file() {
  if ! [[ -f $1 ]]; then
    return 1
  fi
  if ! _autoenv_authorized_env_file $1; then
    echo "Attempting to load unauthorized env file: $1"
    echo ""
    echo "**********************************************"
    echo ""
    cat $1
    echo ""
    echo "**********************************************"
    echo ""
    echo -n "Would you like to authorize it? [y/N] "

    local answer=$(_autoenv_read_answer)
    echo
    if [[ $answer != 'y' ]]; then
      return 1
    fi

    _autoenv_authorize $1
  fi
  return 0
}

# Get directory of this file (absolute, with resolved symlinks).
_autoenv_source_dir=${0:A:h}

_autoenv_source() {
  local env_file=$1
  _autoenv_event=$2
  local _autoenv_envfile_dir=$3

  _autoenv_from_dir=$_autoenv_chpwd_prev_dir
  _autoenv_to_dir=$PWD

  # Source varstash library once.
  if [[ -z "$functions[(I)autostash]" ]]; then
    source $_autoenv_source_dir/lib/varstash
    # NOTE: Varstash uses $PWD as default for varstash_dir, we might set it to
    # ${env_file:h}.
  fi

  # Change to directory of env file, source it and cd back.
  local new_dir=$PWD
  builtin cd -q $_autoenv_envfile_dir
  source $env_file
  builtin cd -q $new_dir

  # Unset vars set for enter/leave scripts.
  # This should not get done for recursion (via autoenv_source_parent),
  # and can be useful to have in general after autoenv was used.
  # unset _autoenv_event _autoenv_from_dir _autoenv_to_dir
}

_autoenv_get_file_upwards() {
  local look_from=${1:-$PWD}
  local look_for=${2:-$AUTOENV_FILE_ENTER}

  # Manually look in parent dirs. An extended Zsh glob should use Y1 for
  # performance reasons, which is only available in zsh-5.0.5-146-g9381bb6.
  local last
  local parent_dir="$look_from/.."
  while true; do
    parent_dir=${parent_dir:A}
    if [[ $parent_dir == $last ]]; then
      break
    fi
    parent_file="${parent_dir}/${look_for}"

    if [[ -f $parent_file ]]; then
      echo $parent_file
      break
    fi

    last=$parent_dir
    parent_dir="${parent_dir}/.."
  done
}


_autoenv_chpwd_prev_dir=$PWD
_autoenv_chpwd_handler() {
  local env_file="$PWD/$AUTOENV_FILE_ENTER"

  # Handle leave event for previously sourced env files.
  if [[ $AUTOENV_HANDLE_LEAVE == 1 ]] && (( $#_autoenv_stack_entered )); then
    local prev_file prev_dir
    for prev_file in ${_autoenv_stack_entered}; do
      prev_dir=${prev_file:A:h}
      if ! [[ ${PWD}/ == ${prev_dir}/* ]]; then
        local env_file_leave=$prev_dir/$AUTOENV_FILE_LEAVE
        if _autoenv_check_authorized_env_file $env_file_leave; then
          _autoenv_source $env_file_leave leave $prev_dir
        fi
        _autoenv_stack_entered_remove $prev_file
      fi
    done
  fi

  if ! [[ -f $env_file ]] && [[ $AUTOENV_LOOK_UPWARDS == 1 ]]; then
    env_file=$(_autoenv_get_file_upwards $PWD)
    if [[ -z $env_file ]]; then
      _autoenv_chpwd_prev_dir=$PWD
      return
    fi
  fi

  # Load the env file only once: check if $env_file is in the stack of entered
  # directories.
  if _autoenv_stack_entered_contains $env_file; then
    _autoenv_chpwd_prev_dir=$PWD
    return
  fi

  if ! _autoenv_check_authorized_env_file $env_file; then
    _autoenv_chpwd_prev_dir=$PWD
    return
  fi

  _autoenv_stack_entered_add $env_file

  # Source the enter env file.
  _autoenv_source $env_file enter $PWD

  _autoenv_chpwd_prev_dir=$PWD
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _autoenv_chpwd_handler

# Look in current directory already.
_autoenv_chpwd_handler
