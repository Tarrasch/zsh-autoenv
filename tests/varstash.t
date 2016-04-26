Test varstash integration.

  $ source $TESTDIR/setup.zsh || return 1

Setup test environment.

  $ mkdir sub
  $ cd sub

The varstash library should not get loaded always.

  $ echo 'echo ENTER' > $AUTOENV_FILE_ENTER
  $ echo 'echo LEAVE' > $AUTOENV_FILE_LEAVE
  $ test_autoenv_auth_env_files
  $ cd .
  ENTER
  $ type -w autostash
  autostash: none
  [1]

Now on to some stashing.

  $ echo 'echo ENTER; autostash FOO=changed' > $AUTOENV_FILE_ENTER
  $ echo 'echo LEAVE; autounstash' > $AUTOENV_FILE_LEAVE
  $ test_autoenv_auth_env_files

Set environment variable.

  $ FOO=orig

Activating the env stashes it and applies a new value.

  $ cd ..
  LEAVE
  $ cd sub
  ENTER
  $ type -w autostash
  autostash: function
  $ echo $FOO
  changed

Leaving the directory unstashes it.

  $ cd ..
  LEAVE
  $ echo $FOO
  orig


Test autounstashing when leaving a directory.  {{{

Setup:

  $ unset VAR
  $ cd sub
  ENTER
  $ echo 'echo ENTER; autostash VAR=changed' >| $AUTOENV_FILE_ENTER
  $ echo 'echo LEAVE; echo "no explicit call to autounstash"' >| $AUTOENV_FILE_LEAVE
  $ test_autoenv_auth_env_files

$VAR is unset:

  $ echo VAR_set:$+VAR
  VAR_set:0

Trigger the autostashing in the enter file.

  $ cd ..
  LEAVE
  no explicit call to autounstash
  $ cd sub
  ENTER
  $ echo $VAR
  changed

Now leave again.

  $ cd ..
  LEAVE
  no explicit call to autounstash
  $ echo VAR_set:$+VAR
  VAR_set:0

Remove the leave file, auto-unstashing should still happen.

  $ rm sub/$AUTOENV_FILE_LEAVE
  $ cd sub
  ENTER
  $ echo $VAR
  changed
  $ cd ..
  $ echo VAR_set:$+VAR
  VAR_set:0

And once again where a value gets restored.

  $ VAR=orig_2
  $ echo $VAR
  orig_2
  $ cd sub
  ENTER
  $ echo $VAR
  changed
  $ cd ..
  $ echo $VAR
  orig_2

}}}
