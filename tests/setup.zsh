# Setup for tests.
#
# It returns 1 in case of errors, and no tests should be run then!
#
# Ensure we have our mocked out AUTOENV_AUTH_FILE
# (via .zshenv).

# Treat unset variables as errors.
# Not handled in varstash yet.
# setopt nounset

export AUTOENV_AUTH_FILE="$CRAMTMP/autoenv/.autoenv_auth"

# Abort this setup script on any error.
_save_errexit=${options[errexit]}
set -e

# Can be defined in .zshenv, e.g. tests/ZDOTDIR.loadviafunction/.zshenv.
if [[ -z $TEST_SOURCE_AUTOENV ]]; then
  TEST_SOURCE_AUTOENV=(source $TESTDIR/../autoenv.plugin.zsh)
fi
$TEST_SOURCE_AUTOENV

# Reset any authentication.
if [[ -f $AUTOENV_AUTH_FILE ]]; then
  echo -n >| $AUTOENV_AUTH_FILE
fi

# Add file ($1), version ($2), and optional hash ($3) to authentication file.
test_autoenv_add_to_env() {
  emulate -L zsh
  [[ -d ${AUTOENV_AUTH_FILE:h} ]] || mkdir -p ${AUTOENV_AUTH_FILE:h}
  _autoenv_deauthorize $1
  {
    local ret_pair
    _autoenv_hash_pair $1 2 ${2:-} && echo $ret_pair
  } >>| $AUTOENV_AUTH_FILE
}

# Add enter and leave env files to authentication file.
test_autoenv_auth_env_files() {
  local dir=${1:-$PWD}
  test_autoenv_add_to_env $dir/$AUTOENV_FILE_ENTER
  test_autoenv_add_to_env $dir/$AUTOENV_FILE_LEAVE
}

# Now keep on going on errors again.
options[errexit]=$_save_errexit
unset _save_errexit
