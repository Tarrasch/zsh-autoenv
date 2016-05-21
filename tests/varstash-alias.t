Test varstash integration with regard to aliases.

  $ source $TESTDIR/setup.zsh || return 1

Setup test environment.

  $ mkdir sub
  $ cd sub
  $ echo 'echo ENTER' > $AUTOENV_FILE_ENTER
  $ echo 'autostash alias some_alias="echo NEW_ALIAS"' >> $AUTOENV_FILE_ENTER
  $ echo 'echo LEAVE' > $AUTOENV_FILE_LEAVE
  $ test_autoenv_auth_env_files

Aliases should be stashed.

  $ alias some_alias="echo ORIG_ALIAS"
  $ some_alias
  ORIG_ALIAS
  $ cd .
  ENTER
  $ some_alias
  NEW_ALIAS
  $ cd ..
  LEAVE
  $ some_alias
  ORIG_ALIAS

Aliases should be stashed, if there are also environment variables.

  $ some_alias=ENV_VAR
  $ some_alias
  ORIG_ALIAS
  $ cd sub
  ENTER
  $ type -w some_alias
  some_alias: alias
  $ echo $some_alias
  ENV_VAR
