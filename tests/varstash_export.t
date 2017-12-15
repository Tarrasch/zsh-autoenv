Test varstash with exported variables in subshell.

  $ source $TESTDIR/setup.zsh || return 1

Setup test environment.

  $ mkdir sub
  $ cd sub
  $ echo 'echo ENTER; autostash MYVAR=changed; autostash MYEXPORT=changed_export' > $AUTOENV_FILE_ENTER
  $ echo 'echo LEAVE; autounstash' > $AUTOENV_FILE_LEAVE

Manually create auth file

  $ test_autoenv_auth_env_files

Set environment variable.

  $ MYVAR=orig
  $ export MYEXPORT=orig_export

Activating the env stashes it and applies a new value.

  $ cd .
  ENTER
  $ echo $MYVAR
  changed
  $ echo $MYEXPORT
  changed_export

The variable is not available in a subshell, only the exported one.

  $ $TESTSHELL -c 'echo ${MYVAR:-empty}; echo $MYEXPORT'
  empty
  changed_export

Activate autoenv in the subshell.

  $ $TESTSHELL -c "$TEST_SOURCE_AUTOENV; echo \${MYVAR}; echo \$MYEXPORT"
  ENTER
  changed
  changed_export

"autounstash" should handle the exported variables.

  $ $TESTSHELL -c "$TEST_SOURCE_AUTOENV; cd ..; echo \${MYVAR:-empty}; echo \$MYEXPORT"
  ENTER
  LEAVE
  empty
  orig_export
