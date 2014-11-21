Test $PWD, $_autoenv_from_dir and _autoenv_to_dir.

  $ source $TESTDIR/setup.sh

Setup env actions / output.

  $ AUTOENV_LOOK_UPWARDS=1
  $ mkdir -p sub/sub2
  $ cd sub
  $ echo 'echo ENTERED: PWD:${PWD:t} from:${_autoenv_from_dir:t} to:${_autoenv_to_dir:t}' > .env
  $ echo 'echo LEFT: PWD:${PWD:t} from:${_autoenv_from_dir:t} to:${_autoenv_to_dir:t}' > .env.leave

Manually create auth files.

  $ test_autoenv_auth_env_files

The actual tests.

  $ cd .
  ENTERED: PWD:sub from:sub to:sub

  $ cd ..
  LEFT: PWD:sub from:sub to:cwd.t

  $ cd sub/sub2
  ENTERED: PWD:sub2 from:cwd.t to:sub2
