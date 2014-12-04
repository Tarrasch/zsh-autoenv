test -f "$TESTDIR/.zcompdump" && rm "$TESTDIR/.zcompdump"

AUTOENV_DEBUG=0

source "$TESTDIR/../autoenv.plugin.zsh"
export AUTOENV_ENV_FILENAME="$PWD/.env_auth"

echo -n > $AUTOENV_ENV_FILENAME
