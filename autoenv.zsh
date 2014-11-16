# Initially based on
# https://github.com/joshuaclayton/dotfiles/blob/master/zsh_profile.d/autoenv.zsh

# TODO: move this to DOTENV_*?!
export ENV_AUTHORIZATION_FILE=$HOME/.env_auth

# Name of file to look for when entering directories.
: ${DOTENV_FILE_ENTER:=.env}

# Name of file to look for when leaving directories.
# Requires DOTENV_HANDLE_LEAVE=1.
: ${DOTENV_FILE_LEAVE:=.env.leave}

# Look for .env in parent dirs?
: ${DOTENV_LOOK_UPWARDS:=0}

# Handle leave events when changing away from a subtree, where an "enter"
# event was handled?
: ${DOTENV_HANDLE_LEAVE:=1}


# Internal: stack of entered (and handled) directories.
_dotenv_stack_entered=()


_dotenv_hash_pair() {
  local env_file=$1
  env_shasum=$(shasum $env_file | cut -d' ' -f1)
  echo "$env_file:$env_shasum"
}

_dotenv_authorized_env_file() {
  local env_file=$1
  local pair=$(_dotenv_hash_pair $env_file)
  test -f $ENV_AUTHORIZATION_FILE \
    && \grep -qF $pair $ENV_AUTHORIZATION_FILE
}

_dotenv_authorize() {
  local env_file=$1
  _dotenv_deauthorize $env_file
  _dotenv_hash_pair $env_file >> $ENV_AUTHORIZATION_FILE
}

_dotenv_deauthorize() {
  local env_file=$1
  if [[ -f $ENV_AUTHORIZATION_FILE ]]; then
    echo $(\grep -vF $env_file $ENV_AUTHORIZATION_FILE) > $ENV_AUTHORIZATION_FILE
  fi
}

# This function can be mocked in tests
_dotenv_read_answer() {
  local answer
  read -q answer
  echo $answer
}

_dotenv_check_authorized_env_file() {
  if ! [[ -f $1 ]]; then
    return 1
  fi
  if ! _dotenv_authorized_env_file $1; then
    echo "Attempting to load unauthorized env file: $1"
    echo ""
    echo "**********************************************"
    echo ""
    cat $1
    echo ""
    echo "**********************************************"
    echo ""
    echo -n "Would you like to authorize it? [y/N] "

    local answer=$(_dotenv_read_answer)
    echo
    if [[ $answer != 'y' ]]; then
      return 1
    fi

    _dotenv_authorize $1
  fi
  return 0
}

# Initialize $_dotenv_sourced_varstash, but do not overwrite an existing one
# from e.g. `exec zsh` (to reload your shell config).
: ${_dotenv_sourced_varstash:=0}

# Get directory of this file (absolute, with resolved symlinks).
_dotenv_this_dir=${0:A:h}

_dotenv_source() {
  local env_file=$1
  _dotenv_event=$2
  _dotenv_cwd=$3

  # Source varstash library once.
  if [[ $_dotenv_sourced_varstash == 0 ]]; then
    source $_dotenv_this_dir/lib/varstash
    export _dotenv_sourced_varstash=1
    # NOTE: Varstash uses $PWD as default for varstash_dir, we might set it to
    # ${env_file:h}.
  fi

  # Change to directory of env file, source it and cd back.
  local new_dir=$PWD
  builtin cd -q $_dotenv_cwd
  source $env_file
  builtin cd -q $new_dir

  unset _dotenv_event _dotenv_cwd
}

_dotenv_chpwd_handler() {
  local env_file="$PWD/$DOTENV_FILE_ENTER"

  # Handle leave event for previously sourced env files.
  if [[ $DOTENV_HANDLE_LEAVE == 1 ]] && (( $#_dotenv_stack_entered )); then
    for prev_dir in ${_dotenv_stack_entered}; do
      if ! [[ ${PWD}/ == ${prev_dir}/* ]]; then
        local env_file_leave=$prev_dir/$DOTENV_FILE_LEAVE
        if _dotenv_check_authorized_env_file $env_file_leave; then
          _dotenv_source $env_file_leave leave $prev_dir
        fi
        # Remove this entry from the stack.
        _dotenv_stack_entered=(${_dotenv_stack_entered#$prev_dir})
      fi
    done
  fi

  if ! [[ -f $env_file ]] && [[ $DOTENV_LOOK_UPWARDS == 1 ]]; then
    setopt localoptions extendedglob
    local m
    m=((../)#${DOTENV_FILE_ENTER}(N))
    if (( $#m )); then
      env_file=${${m[1]}:A}
    else
      return
    fi
  fi

  if ! _dotenv_check_authorized_env_file $env_file; then
    return
  fi

  # Load the env file only once.
  if (( ${+_dotenv_stack_entered[(r)${env_file:A:h}]} )); then
    return
  fi

  _dotenv_stack_entered+=(${env_file:A:h})

  _dotenv_source $env_file enter $PWD
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _dotenv_chpwd_handler

# Look in current directory already.
_dotenv_chpwd_handler
