Test $PWD, $autoenv_event, $autoenv_from_dir and $autoenv_to_dir.

  $ source $TESTDIR/setup.zsh || return 1

Setup env actions / output.

  $ AUTOENV_LOOK_UPWARDS=1
  $ mkdir -p sub/sub2
  $ cd sub
  $ echo 'echo ENTERED: PWD:${PWD:t} pwd:${${"$(pwd)"}:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t} event:${autoenv_event}' > .autoenv.zsh
  $ echo 'echo LEFT: PWD:${PWD:t} pwd:${${"$(pwd)"}:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t} event:${autoenv_event}' > .autoenv_leave.zsh

Manually create auth files.

  $ test_autoenv_auth_env_files

The actual tests.

  $ cd .
  ENTERED: PWD:sub pwd:sub from:sub to:sub event:enter

  $ cd ..
  LEFT: PWD:cwd.t pwd:cwd.t from:sub to:cwd.t event:leave

  $ cd sub/sub2
  ENTERED: PWD:sub2 pwd:sub2 from:cwd.t to:sub2 event:enter

Check that symlinked dirs get handled correctly.

  $ cd ../..
  LEFT: PWD:cwd.t pwd:cwd.t from:sub2 to:cwd.t event:leave
  $ ln -s sub sub_linked
  $ cd sub_linked
  ENTERED: PWD:sub_linked pwd:sub_linked from:cwd.t to:sub_linked event:enter
  $ cd sub2

  $ cd ../..
  LEFT: PWD:cwd.t pwd:cwd.t from:sub2 to:cwd.t event:leave
  $ cd sub_linked/sub2
  ENTERED: PWD:sub2 pwd:sub2 from:cwd.t to:sub2 event:enter
