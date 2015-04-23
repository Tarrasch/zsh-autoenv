Tests for internal stack handling.

  $ source $TESTDIR/setup.zsh || return 1

Non-existing entries are allowed and handled without error.

  $ _autoenv_stack_entered_add non-existing
  $ echo $_autoenv_stack_entered
  non-existing

Add existing entries.

  $ mkdir -p sub/sub2
  $ touch -t 201401010101 sub/file
  $ touch -t 201401010102 sub
  $ touch -t 201401010103 sub/sub2
  $ _autoenv_stack_entered_add sub
  $ _autoenv_stack_entered_add sub/file
  $ _autoenv_stack_entered_add sub/sub2
  $ echo $_autoenv_stack_entered
  non-existing sub sub/file sub/sub2

  $ _autoenv_stack_entered_add non-existing
  $ echo $_autoenv_stack_entered
  sub sub/file sub/sub2 non-existing

  $ echo ${(k)_autoenv_stack_entered}
  sub sub/file sub/sub2 non-existing

  $ echo $_autoenv_stack_entered_mtime
  1388538180 1388538060 1388538120 0

Touch the file and re-add it.

  $ touch -t 201401012359 sub/file
  $ _autoenv_stack_entered_add sub/file

The mtime should have been updated.

  $ echo ${_autoenv_stack_entered_mtime[sub/file]}
  1388620740

It should have moved to the end of the stack.

  $ echo ${(k)_autoenv_stack_entered}
  sub sub/sub2 non-existing sub/file

Test lookup of containing elements.

  $ _autoenv_stack_entered_contains sub/file
  $ _autoenv_stack_entered_contains non-existing
  $ _autoenv_stack_entered_contains not-added
  [1]

Test removing.

  $ _autoenv_stack_entered_remove sub
  $ echo ${_autoenv_stack_entered}
  sub/sub2 non-existing sub/file

