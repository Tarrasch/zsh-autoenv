Test varstash integration.

  $ source $TESTDIR/setup.sh

Setup test environment.

# Defaults:
# $ DOTENV_FILE_ENTER=.env
# $ DOTENV_FILE_LEAVE=.env.leave
# $ DOTENV_HANDLE_LEAVE=1

  $ mkdir sub
  $ cd sub
  $ echo "autostash FOO=baz" > $DOTENV_FILE_ENTER
  $ echo "autounstash" > $DOTENV_FILE_LEAVE

Manually create auth file

  $ echo "$PWD/$DOTENV_FILE_ENTER:$(echo $(<$DOTENV_FILE_ENTER) | shasum)" > $ENV_AUTHORIZATION_FILE
  $ echo "$PWD/$DOTENV_FILE_LEAVE:$(echo $(<$DOTENV_FILE_LEAVE) | shasum)" >> $ENV_AUTHORIZATION_FILE

Set environment variable.

  $ FOO=bar

Activating the env stashes it and applies a new value.

  $ cd .
  $ echo $FOO
  baz

Leaving the directory unstashes it.

  $ cd ..
  $ echo $FOO
  bar
