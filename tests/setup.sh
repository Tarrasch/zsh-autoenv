# Ensure we have our mocked out AUTOENV_ENV_FILENAME
# (via .zshenv).

[[ $AUTOENV_ENV_FILENAME[0,4] == '/tmp' ]] || return 1

# Reset any authentication.
echo -n > $AUTOENV_ENV_FILENAME

# Inject timeout for `read` while running tests.
_AUTOENV_TEST_READ_ARGS='-t 1'

# Add file $1 (with optional hash $2) to authentication file.
test_autoenv_add_to_env() {
  _autoenv_hash_pair $1 $2 >> $AUTOENV_ENV_FILENAME
}

# Add enter and leave env files to authentication file.
test_autoenv_auth_env_files() {
  test_autoenv_add_to_env $PWD/$AUTOENV_FILE_ENTER
  test_autoenv_add_to_env $PWD/$AUTOENV_FILE_LEAVE
}
