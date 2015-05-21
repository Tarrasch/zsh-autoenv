Tests for internal util methods.

  $ source $TESTDIR/setup.zsh || return 1

Non-existing entries are allowed and handled without error.

  $ mkdir -p sub/sub2
  $ touch file sub/file sub/sub2/file

Should not get the file from the current dir.

  $ _autoenv_get_file_upwards . file

  $ cd sub/sub2
  $ _autoenv_get_file_upwards . file
  */_autoenv_utils.t/sub/file (glob)


Tests for _autoenv_authorize. {{{

Auth file is empty.

  $ cd ../..
  $ cat $AUTOENV_AUTH_FILE

Failed authorization should keep the auth file empty.

  $ _autoenv_authorize does-not-exist
  Missing file argument for _autoenv_hash_pair!
  [1]
  $ cat $AUTOENV_AUTH_FILE

Now adding some auth pair.

  $ echo first > first
  $ _autoenv_authorize first
  $ cat $AUTOENV_AUTH_FILE
  :/tmp/cramtests-*/_autoenv_utils.t/first:271ac93c44ac198d92e706c6d6f1d84aefcfa337:1 (glob)

And a second one.

  $ echo second > second
  $ _autoenv_authorize second
  $ cat $AUTOENV_AUTH_FILE
  :/tmp/cramtests-*/_autoenv_utils.t/first:271ac93c44ac198d92e706c6d6f1d84aefcfa337:1 (glob)
  :/tmp/cramtests-*/_autoenv_utils.t/second:7bee8f3b184e1e141ff76efe369c3b8bfc50e64c:1 (glob)

And a third.

  $ echo third > third
  $ _autoenv_authorize third
  $ cat $AUTOENV_AUTH_FILE
  :/tmp/cramtests-*/_autoenv_utils.t/first:271ac93c44ac198d92e706c6d6f1d84aefcfa337:1 (glob)
  :/tmp/cramtests-*/_autoenv_utils.t/second:7bee8f3b184e1e141ff76efe369c3b8bfc50e64c:1 (glob)
  :/tmp/cramtests-*/_autoenv_utils.t/third:ad180453bf8a374a15df3e90a78c180230146a7c:1 (glob)

Re-add the second one, with the same hash.

  $ _autoenv_authorize second
  $ cat $AUTOENV_AUTH_FILE
  :/tmp/cramtests-*/_autoenv_utils.t/first:271ac93c44ac198d92e706c6d6f1d84aefcfa337:1 (glob)
  :/tmp/cramtests-*/_autoenv_utils.t/third:ad180453bf8a374a15df3e90a78c180230146a7c:1 (glob)
  :/tmp/cramtests-*/_autoenv_utils.t/second:7bee8f3b184e1e141ff76efe369c3b8bfc50e64c:1 (glob)

Re-add the first one, with a new hash.

  $ echo one more line >> first
  $ _autoenv_authorize first
  $ cat $AUTOENV_AUTH_FILE
  :/tmp/cramtests-*/_autoenv_utils.t/third:ad180453bf8a374a15df3e90a78c180230146a7c:1 (glob)
  :/tmp/cramtests-*/_autoenv_utils.t/second:7bee8f3b184e1e141ff76efe369c3b8bfc50e64c:1 (glob)
  :/tmp/cramtests-*/_autoenv_utils.t/first:65eb010197b73ddc109b7210080f97a87f53451e:1 (glob)
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
