Tests for provided utils/helpers.

  $ source $TESTDIR/setup.zsh || return 1

  $ PATH=
  $ autoenv_prepend_path custom_path
  $ echo $PATH
  custom_path

  $ autoenv_prepend_path custom_path
  $ echo $PATH
  custom_path

  $ autoenv_prepend_path another_path a_third_one
  $ echo $PATH
  a_third_one:another_path:custom_path

  $ autoenv_remove_path another_path a_third_one
  $ echo $PATH
  custom_path

  $ autoenv_remove_path does_not_exist
  [1]
  $ echo $PATH
  custom_path

  $ autoenv_remove_path custom_path
  $ echo PATH:$PATH
  PATH:
