# Ensure we have our mocked out AUTOENV_ENV_FILENAME
# (via .zshenv).

[[ $AUTOENV_ENV_FILENAME[0,4] == '/tmp' ]] || return 1

# Inject timeout for `read` while running tests.
_AUTOENV_TEST_READ_ARGS='-t 1'

test_autoenv_add_to_env() {
  _dotenv_hash_pair $1 $2 >> $AUTOENV_ENV_FILENAME
}

# Add enter and leave env files to authentication file.
test_autoenv_auth_env_files() {
  echo -n > $AUTOENV_ENV_FILENAME
  test_autoenv_add_to_env $PWD/$DOTENV_FILE_ENTER
  test_autoenv_add_to_env $PWD/$DOTENV_FILE_LEAVE
}
