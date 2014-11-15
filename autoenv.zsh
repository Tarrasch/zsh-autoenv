# Stolen from
# https://github.com/joshuaclayton/dotfiles/blob/master/zsh_profile.d/autoenv.zsh

# TODO: move this to DOTENV_*?!
export ENV_AUTHORIZATION_FILE=$HOME/.env_auth

: ${DOTENV_FILE_ENTER:=.env}
: ${DOTENV_FILE_LEAVE:=.env.leave}

# Look for .env in parent dirs?
: ${DOTENV_LOOK_UPWARDS:=0}

# Handle leave events, when leaving ?
: ${DOTENV_HANDLE_LEAVE:=1}


_dotenv_hash_pair() {
  local env_file=$1
  env_shasum=$(shasum $env_file | cut -d' ' -f1)
  echo "$env_file:$env_shasum"
}

_dotenv_authorized_env_file() {
  local env_file=$1
  local pair=$(_dotenv_hash_pair $env_file)
  touch $ENV_AUTHORIZATION_FILE
  \grep -Gq $pair $ENV_AUTHORIZATION_FILE
}

_dotenv_authorize() {
  local env_file=$1
  _dotenv_deauthorize $env_file
  _dotenv_hash_pair $env_file >> $ENV_AUTHORIZATION_FILE
}

_dotenv_deauthorize() {
  local env_file=$1
  echo $(\grep -Gv $env_file $ENV_AUTHORIZATION_FILE) > $ENV_AUTHORIZATION_FILE
}

_dotenv_print_unauthorized_message() {
  echo "Attempting to load unauthorized env file: $1"
  echo ""
  echo "**********************************************"
  echo ""
  cat $1
  echo ""
  echo "**********************************************"
  echo ""
  echo -n "Would you like to authorize it? [y/N] "
}

# This function can be mocked in tests
_dotenv_read_answer() {
  local answer
  read -q answer
  echo $answer
}

_dotenv_check_authorized_env_file() {
  if ! _dotenv_authorized_env_file $1; then
    _dotenv_print_unauthorized_message $1

    local answer=$(_dotenv_read_answer)
    echo
    if [[ $answer != 'y' ]]; then
      return 1
    fi

    _dotenv_authorize $1
  fi
  return 0
}

_dotenv_stack_entered=()

_dotenv_chpwd_handler() {
  local env_file="$PWD/$DOTENV_FILE_ENTER"

  # Handle leave event for previously sourced env files.
  if [[ $DOTENV_HANDLE_LEAVE == 1 ]] && (( $#_dotenv_stack_entered )); then
    for prev_dir in ${_dotenv_stack_entered}; do
      if ! [[ ${PWD}/ == ${prev_dir}/* ]]; then
        local env_file_leave=$prev_dir/$DOTENV_FILE_LEAVE
        if _dotenv_check_authorized_env_file $env_file_leave; then
          _dotenv_event=leave
          source $env_file_leave
          unset _dotenv_event
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
      env_file=$m[1]
    fi
  fi

  if ! [[ -f $env_file ]]; then
    return
  fi

  if ! _dotenv_check_authorized_env_file $env_file; then
    return
  fi

  # Load the env file only once.
  if (( ${+_dotenv_stack_entered[(r)${env_file:A:h}]} )); then
    return
  fi

  _dotenv_stack_entered+=(${env_file:A:h})

  _dotenv_event=enter
  source $env_file
  unset _dotenv_event
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _dotenv_chpwd_handler

# Look in current directory already.
_dotenv_chpwd_handler
