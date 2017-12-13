Test unstash behavior on leaving.

  $ source $TESTDIR/setup.zsh || return 1

Setup test environment.

  $ mkdir -p sub/sub2
  $ echo 'echo ENTER; stash FOO=changed' >| sub/$AUTOENV_FILE_ENTER
  $ echo 'echo LEAVE; unstash FOO' >| sub/$AUTOENV_FILE_LEAVE
  $ test_autoenv_auth_env_files sub
  $ FOO=orig

Activating the env stashes it and applies a new value.

  $ cd sub/sub2
  ENTER
  $ echo $FOO
  changed

Leaving the directory unstashes it (varstash_dir is set to prev dir).

  $ cd -
  LEAVE
  $ echo $FOO
  orig
