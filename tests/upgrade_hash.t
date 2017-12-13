Tests for upgrading hashes.

  $ source $TESTDIR/setup.zsh || return 1

  $ mkdir -p sub
  $ mkdir -p ${AUTOENV_AUTH_FILE:h}

Create a single v1 hash entry.

  $ echo 'echo ENTERED' > sub/$AUTOENV_FILE_ENTER
  $ echo 'echo LEAVE' > sub/$AUTOENV_FILE_LEAVE

  $ echo :$PWD/sub/$AUTOENV_FILE_ENTER:4c403f1870af2ab5472370a42b6b2b488cefe83c:1 >| $AUTOENV_AUTH_FILE
  $ cd sub
  ENTERED

Hashes should get upgraded automatically.
This also tests that there are no empty lines being added to the auth file when
de-authenticating the old hash.

  $ cat $AUTOENV_AUTH_FILE
  :/*/cramtests-*/upgrade_hash.t/sub/.autoenv.zsh:3679467995.13:2 (glob)

Re-create auth file with v1 hashes for both auth files.

  $ echo :$PWD/$AUTOENV_FILE_LEAVE:882cf0333ea3c35537c9459c08d8987f25087ea9:1 >| $AUTOENV_AUTH_FILE
  $ echo :$PWD/$AUTOENV_FILE_ENTER:4c403f1870af2ab5472370a42b6b2b488cefe83c:1 >>| $AUTOENV_AUTH_FILE

Only the leave file's hash should get updated.

  $ cd ..
  LEAVE
  $ cat $AUTOENV_AUTH_FILE
  :/*/cramtests-*/upgrade_hash.t/sub/.autoenv.zsh:4c403f1870af2ab5472370a42b6b2b488cefe83c:1 (glob)
  :/*/cramtests-*/upgrade_hash.t/sub/.autoenv_leave.zsh:803077150.11:2 (glob)

The enter file's hash should get updated.

  $ cd sub
  ENTERED
  $ cat $AUTOENV_AUTH_FILE
  :/*/cramtests-*/upgrade_hash.t/sub/.autoenv_leave.zsh:803077150.11:2 (glob)
  :/*/cramtests-*/upgrade_hash.t/sub/.autoenv.zsh:3679467995.13:2 (glob)
