Test $PWD, $autoenv_event, $autoenv_from_dir and $autoenv_to_dir.

  $ source $TESTDIR/setup.sh

Setup env actions / output.

  $ AUTOENV_LOOK_UPWARDS=1
  $ mkdir -p sub/sub2
  $ cd sub
  $ echo 'echo ENTERED: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t} event:${autoenv_event}' > .env
  $ echo 'echo LEFT: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t} event:${autoenv_event}' > .env.leave

Manually create auth files.

  $ test_autoenv_auth_env_files

The actual tests.

  $ cd .
  ENTERED: PWD:sub from:sub to:sub event:enter

  $ cd ..
  LEFT: PWD:sub from:sub to:cwd.t event:leave

  $ cd sub/sub2
  ENTERED: PWD:sub from:cwd.t to:sub2 event:enter

Check that symlinked dirs get handled correctly.

  $ cd ../..
  LEFT: PWD:sub from:sub2 to:cwd.t event:leave
  $ ln -s sub sub_linked
  $ cd sub_linked
  ENTERED: PWD:sub from:cwd.t to:sub_linked event:enter
  $ cd sub2
  ENTERED: PWD:sub from:sub_linked to:sub2 event:enter
  $ cd .
