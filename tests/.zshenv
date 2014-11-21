test -f "$TESTDIR/.zcompdump" && rm "$TESTDIR/.zcompdump"

source "$TESTDIR/../autoenv.plugin.zsh"
export AUTOENV_ENV_FILENAME="$PWD/.env_auth"
