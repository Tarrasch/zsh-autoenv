test -f "$TESTDIR/.zcompdump" && rm "$TESTDIR/.zcompdump"

AUTOENV_DEBUG=0

antigen-like-loader-function() {
  source "$TESTDIR/../autoenv.plugin.zsh"
}
antigen-like-loader-function

export AUTOENV_ENV_FILENAME="$PWD/.env_auth"

echo -n > $AUTOENV_ENV_FILENAME
