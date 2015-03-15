test -f "$TESTDIR/.zcompdump" && rm "$TESTDIR/.zcompdump"

AUTOENV_DEBUG=0

export AUTOENV_ENV_FILENAME="$PWD/.env_auth"

echo -n > $AUTOENV_ENV_FILENAME
