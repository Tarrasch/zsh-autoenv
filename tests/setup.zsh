# Setup for tests.
#
# It returns 1 in case of errors, and no tests should be run then!
#
# Ensure we have our mocked out AUTOENV_AUTH_FILE
# (via .zshenv).

# Treat unset variables as errors.
# Not handled in varstash yet.
# setopt nounset

export AUTOENV_AUTH_FILE="$CRAMTMP/.autoenv_auth"

if [[ $AUTOENV_AUTH_FILE[0,4] != '/tmp' ]]; then
  echo "AUTOENV_AUTH_FILE is not in /tmp. Aborting."
  return 1
fi

# Abort this setup script on any error.
_save_errexit=${options[errexit]}
set -e

# Defined in .zshenv, e.g. tests/ZDOTDIR/.zshenv.
$TEST_SOURCE_AUTOENV

# Reset any authentication.
echo -n >| $AUTOENV_AUTH_FILE

# Add file $1 (with optional hash $2) to authentication file.
test_autoenv_add_to_env() {
  _autoenv_hash_pair $1 ${2:-} >>| $AUTOENV_AUTH_FILE
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
