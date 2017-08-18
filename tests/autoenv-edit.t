  $ source $TESTDIR/setup.zsh || return 1

  $ export EDITOR=echo

  $ autoenv-edit
  No .autoenv.zsh file found (enter).
  No .autoenv_leave.zsh file found (leave).
  [1]

  $ touch .autoenv.zsh
  $ autoenv-edit
  No .autoenv_leave.zsh file found (leave).
  Editing .autoenv.zsh..
  .autoenv.zsh

  $ AUTOENV_FILE_LEAVE=$AUTOENV_FILE_ENTER
  $ autoenv-edit
  Editing .autoenv.zsh..
  .autoenv.zsh (glob)

  $ mkdir sub
  $ cd -q sub
  $ autoenv-edit
  Editing ../.autoenv.zsh..
  ../.autoenv.zsh

Supports command with args for EDITOR.

  $ export EDITOR='printf file:%s\\n'
  $ autoenv-edit
  Editing ../.autoenv.zsh..
  file:../.autoenv.zsh

Supports alias for EDITOR.

  $ alias myeditor_alias='printf file:%s'
  $ export EDITOR=myeditor_alias
  $ autoenv-edit
  Editing ../.autoenv.zsh..
  file:../.autoenv.zsh (no-eol)

Falls back to "vim" for EDITOR.

  $ alias vim='printf vim_file:%s'
  $ unset EDITOR
  $ autoenv-edit
  Editing ../.autoenv.zsh..
  vim_file:../.autoenv.zsh (no-eol)

Note with AUTOENV_LOOK_UPWARDS=0

  $ EDITOR=true
  $ AUTOENV_LOOK_UPWARDS=0
  $ autoenv-edit
  Note: found ../.autoenv.zsh, but AUTOENV_LOOK_UPWARDS is disabled.
  Editing ../.autoenv.zsh..

  $ AUTOENV_FILE_LEAVE=.autoenv_leave.zsh
  $ touch ../$AUTOENV_FILE_LEAVE
  $ autoenv-edit
  Note: found ../.autoenv.zsh, but AUTOENV_LOOK_UPWARDS is disabled.
  Note: found ../.autoenv_leave.zsh, but AUTOENV_LOOK_UPWARDS is disabled.
  Editing ../.autoenv.zsh ../.autoenv_leave.zsh..

  $ touch $AUTOENV_FILE_LEAVE
  $ autoenv-edit
  Note: found ../.autoenv.zsh, but AUTOENV_LOOK_UPWARDS is disabled.
  Editing ../.autoenv.zsh .autoenv_leave.zsh..
