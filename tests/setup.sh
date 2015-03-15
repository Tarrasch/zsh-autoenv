# Setup for tests.
#
# It returns 1 in case of errors, and no tests should be run then!
#
# Ensure we have our mocked out AUTOENV_ENV_FILENAME
# (via .zshenv).

# Treat unset variables as errors.
# Not handled in varstash yet.
# setopt nounset

if [[ $AUTOENV_ENV_FILENAME[0,4] != '/tmp' ]]; then
  echo "AUTOENV_ENV_FILENAME is not in /tmp. Aborting."
  return 1
fi

TEST_AUTOENV_PLUGIN_FILE="$TESTDIR/../autoenv.plugin.zsh"
source $TEST_AUTOENV_PLUGIN_FILE

# Reset any authentication.
echo -n >| $AUTOENV_ENV_FILENAME

# Add file $1 (with optional hash $2) to authentication file.
test_autoenv_add_to_env() {
  _autoenv_hash_pair $1 ${2:-} >>| $AUTOENV_ENV_FILENAME
}

# Add enter and leave env files to authentication file.
test_autoenv_auth_env_files() {
  test_autoenv_add_to_env $PWD/$AUTOENV_FILE_ENTER
  test_autoenv_add_to_env $PWD/$AUTOENV_FILE_LEAVE
}
