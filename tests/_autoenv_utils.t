Tests for internal util methods.

  $ source $TESTDIR/setup.zsh || return 1

Non-existing entries are allowed and handled without error.

  $ mkdir -p sub/sub2
  $ touch file sub/file sub/sub2/file

Should not get the file from the current dir.

  $ _autoenv_get_file_upwards . file

  $ cd sub/sub2
  $ _autoenv_get_file_upwards . file
  ../file
  $ _autoenv_get_file_upwards $PWD file
  */_autoenv_utils.t/sub/file (glob)

_autoenv_get_file_upwards should not dereference symlinks.

  $ cd ../..
  $ ln -s sub symlink
  $ cd symlink/sub2
  $ _autoenv_get_file_upwards . file
  ../file
  $ _autoenv_get_file_upwards $PWD file
  */_autoenv_utils.t/symlink/file (glob)

Tests for _autoenv_authorize. {{{

Auth file is empty.

  $ cd ../..
  $ ! [[ -f "$AUTOENV_AUTH_FILE" ]] || cat $AUTOENV_AUTH_FILE

Failed authorization should keep the auth file empty.

  $ _autoenv_authorize does-not-exist
  Missing file argument for _autoenv_hash_pair!
  [1]
  $ cat $AUTOENV_AUTH_FILE

Now adding some auth pair.

  $ echo first > first
  $ _autoenv_authorize first
  $ cat $AUTOENV_AUTH_FILE
  :/*/cramtests-*/_autoenv_utils.t/first:2715464726.6:2 (glob)

And a second one.

  $ echo second > second
  $ _autoenv_authorize second
  $ cat $AUTOENV_AUTH_FILE
  :/*/cramtests-*/_autoenv_utils.t/first:2715464726.6:2 (glob)
  :/*/cramtests-*/_autoenv_utils.t/second:594940475.7:2 (glob)

And a third.

  $ echo third > third
  $ _autoenv_authorize third
  $ cat $AUTOENV_AUTH_FILE
  :/*/cramtests-*/_autoenv_utils.t/first:2715464726.6:2 (glob)
  :/*/cramtests-*/_autoenv_utils.t/second:594940475.7:2 (glob)
  :/*/cramtests-*/_autoenv_utils.t/third:451243482.6:2 (glob)

Re-add the second one, with the same hash.

  $ _autoenv_authorize second
  $ cat $AUTOENV_AUTH_FILE
  :/*/cramtests-*/_autoenv_utils.t/first:2715464726.6:2 (glob)
  :/*/cramtests-*/_autoenv_utils.t/third:451243482.6:2 (glob)
  :/*/cramtests-*/_autoenv_utils.t/second:594940475.7:2 (glob)

Re-add the first one, with a new hash.

  $ echo one more line >> first
  $ _autoenv_authorize first
  $ cat $AUTOENV_AUTH_FILE
  :/*/cramtests-*/_autoenv_utils.t/third:451243482.6:2 (glob)
  :/*/cramtests-*/_autoenv_utils.t/second:594940475.7:2 (glob)
  :/*/cramtests-*/_autoenv_utils.t/first:3620404822.20:2 (glob)
}}}


Explicit calls to _autoenv_get_file_mtime to test alternative implementation
of _autoenv_get_file_mtime (via ZDOTDIR.invalid-module_path/).

  $ _autoenv_get_file_mtime non-existing
  0
  $ touch -t 201401010101 file
  $ _autoenv_get_file_mtime file
  1388538060
  $ mkdir dir
  $ touch -t 201401010102 dir
  $ _autoenv_get_file_mtime dir
  1388538120

Stops when last (absolute) path does not change anymore.

  $ _autoenv_get_file_upwards / doesnotexist nevermatches
