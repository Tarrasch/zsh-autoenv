# Ensure we have our mocked out ENV_AUTHORIZATION_FILE

[[ $ENV_AUTHORIZATION_FILE[0,4] == '/tmp' ]] || return 1

# Inject timeout for `read` while running tests.
_AUTOENV_TEST_READ_ARGS='-t 1'
