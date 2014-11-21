Test varstash integration.

  $ source $TESTDIR/setup.sh

Setup test environment.

  $ mkdir sub
  $ cd sub
  $ echo "autostash FOO=baz" > $DOTENV_FILE_ENTER
  $ echo "autounstash" > $DOTENV_FILE_LEAVE

Manually create auth file

  $ test_autoenv_auth_env_files

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
