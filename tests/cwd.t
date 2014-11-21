Test $PWD and $_dotenv_cwd.

  $ source $TESTDIR/setup.sh

Setup env actions / output.

  $ DOTENV_LOOK_UPWARDS=1
  $ mkdir -p sub/sub2
  $ cd sub
  $ echo 'echo ENTERED: cwd:${PWD:t} ${_dotenv_cwd:t}' >> .env
  $ echo 'echo LEFT: cwd:${PWD:t} ${_dotenv_cwd:t}' >> .env.leave

Manually create auth files.

  $ test_autoenv_auth_env_files

The actual tests.

  $ cd .
  ENTERED: cwd:sub sub

  $ cd ..
  LEFT: cwd:sub cwd.t

  $ cd sub/sub2
  ENTERED: cwd:sub sub2
