Test vars with autoenv_source_parent.

  $ source $TESTDIR/setup.zsh || return 1

Setup env actions / output.

  $ AUTOENV_LOOK_UPWARDS=1

Create env files in root dir.

  $ echo 'echo ENTERED_root: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv.zsh
  $ echo 'echo LEFT_root: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv_leave.zsh
  $ test_autoenv_auth_env_files

Create env files in sub dir.

  $ mkdir -p sub/sub2
  $ echo 'echo ENTERED_sub: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > sub/.autoenv.zsh
  $ echo 'echo LEFT_sub: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > sub/.autoenv_leave.zsh
  $ test_autoenv_auth_env_files sub

  $ echo 'echo ENTERED_sub2: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > sub/sub2/.autoenv.zsh
  $ echo 'echo LEFT_sub2: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > sub/sub2/.autoenv_leave.zsh
  $ echo 'echo autoenv_source_parent_from_sub2\n' >> sub/sub2/.autoenv.zsh
  $ echo 'echo autoenv_env_file_1:${autoenv_env_file:h:t}\nautoenv_source_parent\n' >> sub/sub2/.autoenv.zsh
  $ echo 'echo autoenv_env_file_2:${autoenv_env_file:h:t}\necho done_sub3\n' >> sub/sub2/.autoenv.zsh
  $ test_autoenv_auth_env_files sub/sub2

The actual tests.

  $ cd sub/sub2
  ENTERED_sub2: PWD:sub2 from:source-parent-vars.t to:sub2
  autoenv_source_parent_from_sub2
  autoenv_env_file_1:sub2
  ENTERED_sub: PWD:sub2 from:source-parent-vars.t to:sub2
  autoenv_env_file_2:sub2
  done_sub3

