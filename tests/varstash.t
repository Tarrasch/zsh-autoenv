Test varstash integration.

  $ source $TESTDIR/setup.sh

Setup test environment.

  $ mkdir sub
  $ cd sub
  $ echo 'echo ENTER; autostash FOO=baz' > $AUTOENV_FILE_ENTER
  $ echo 'echo LEAVE; autounstash' > $AUTOENV_FILE_LEAVE

Manually create auth file

  $ test_autoenv_auth_env_files

Set environment variable.

  $ FOO=bar

Activating the env stashes it and applies a new value.

  $ cd .
  ENTER
  $ echo $FOO
  baz

Leaving the directory unstashes it.

  $ cd ..
  LEAVE
  $ echo $FOO
  bar
