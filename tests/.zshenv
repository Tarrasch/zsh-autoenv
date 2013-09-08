test -f "$TESTDIR/.zcompdump" && rm "$TESTDIR/.zcompdump"

source "$TESTDIR/../autoenv.plugin.zsh"
export ENV_AUTHORIZATION_FILE="$PWD/.env_auth"
