# Ensure we have our mocked out AUTOENV_ENV_FILENAME

[[ $AUTOENV_ENV_FILENAME[0,4] == '/tmp' ]] || return 1

# Inject timeout for `read` while running tests.
_AUTOENV_TEST_READ_ARGS='-t 1'
