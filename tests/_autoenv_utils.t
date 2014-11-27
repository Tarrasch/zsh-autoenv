Tests for internal util methods.

  $ source $TESTDIR/setup.sh

Non-existing entries are allowed and handled without error.

  $ mkdir -p sub/sub2
  $ touch file sub/file sub/sub2/file

Should not get the file from the current dir.
  $ _autoenv_get_file_upwards . file

  $ cd sub/sub2
  $ _autoenv_get_file_upwards . file
  */_autoenv_utils.t/sub/file (glob)
