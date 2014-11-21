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


# Internal: stack of entered (and handled) directories.
_autoenv_stack_entered=()


_autoenv_hash_pair() {
  local env_file=$1
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

# Initialize $_autoenv_sourced_varstash, but do not overwrite an existing one
# from e.g. `exec zsh` (to reload your shell config).
: ${_autoenv_sourced_varstash:=0}

# Get directory of this file (absolute, with resolved symlinks).
_autoenv_this_dir=${0:A:h}

_autoenv_source() {
  local env_file=$1
  _autoenv_event=$2
  _autoenv_envfile_dir=$3
  _autoenv_from_dir=$_autoenv_chpwd_prev_dir
  _autoenv_to_dir=$PWD

  # Source varstash library once.
  if [[ $_autoenv_sourced_varstash == 0 ]]; then
    source $_autoenv_this_dir/lib/varstash
    export _autoenv_sourced_varstash=1
    # NOTE: Varstash uses $PWD as default for varstash_dir, we might set it to
    # ${env_file:h}.
  fi

  # Change to directory of env file, source it and cd back.
  local new_dir=$PWD
  builtin cd -q $_autoenv_envfile_dir
  source $env_file
  builtin cd -q $new_dir

  unset _autoenv_event _autoenv_from_dir
}

_autoenv_chpwd_prev_dir=$PWD
_autoenv_chpwd_handler() {
  local env_file="$PWD/$AUTOENV_FILE_ENTER"

  # Handle leave event for previously sourced env files.
  if [[ $AUTOENV_HANDLE_LEAVE == 1 ]] && (( $#_autoenv_stack_entered )); then
    for prev_dir in ${_autoenv_stack_entered}; do
      if ! [[ ${PWD}/ == ${prev_dir}/* ]]; then
        local env_file_leave=$prev_dir/$AUTOENV_FILE_LEAVE
        if _autoenv_check_authorized_env_file $env_file_leave; then
          _autoenv_source $env_file_leave leave $prev_dir
        fi
        # Remove this entry from the stack.
        _autoenv_stack_entered=(${_autoenv_stack_entered#$prev_dir})
      fi
    done
  fi

  if ! [[ -f $env_file ]] && [[ $AUTOENV_LOOK_UPWARDS == 1 ]]; then
    # Look for files in parent dirs, using an extended Zsh glob.
    setopt localoptions extendedglob
    local m
    m=((../)#${AUTOENV_FILE_ENTER}(N))
    if (( $#m )); then
      env_file=${${m[1]}:A}
    else
      _autoenv_chpwd_prev_dir=$PWD
      return
    fi
  fi

  if ! _autoenv_check_authorized_env_file $env_file; then
    _autoenv_chpwd_prev_dir=$PWD
    return
  fi

  # Load the env file only once: check if $env_file's parent
  # is in $_autoenv_stack_entered.
  local env_file_dir=${env_file:A:h}
  if (( ${+_autoenv_stack_entered[(r)${env_file_dir}]} )); then
    _autoenv_chpwd_prev_dir=$PWD
    return
  fi

  _autoenv_stack_entered+=(${env_file_dir})

  _autoenv_source $env_file enter $PWD

  _autoenv_chpwd_prev_dir=$PWD
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _autoenv_chpwd_handler

# Look in current directory already.
_autoenv_chpwd_handler
