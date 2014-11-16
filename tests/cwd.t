Test $PWD and $_dotenv_cwd.

Ensure we have our mocked out ENV_AUTHORIZATION_FILE.

  $ [[ $ENV_AUTHORIZATION_FILE[0,4] == '/tmp' ]] || return 1

Setup env actions / output.

  $ DOTENV_LOOK_UPWARDS=1
  $ mkdir -p sub/sub2
  $ cd sub
  $ echo 'echo ENTERED: cwd:${PWD:t} ${_dotenv_cwd:t}' >> .env
  $ echo 'echo LEFT: cwd:${PWD:t} ${_dotenv_cwd:t}' >> .env.leave

Manually create auth files.

  $ echo "$PWD/$DOTENV_FILE_ENTER:$(echo $(<$DOTENV_FILE_ENTER) | shasum)" > $ENV_AUTHORIZATION_FILE
  $ echo "$PWD/$DOTENV_FILE_LEAVE:$(echo $(<$DOTENV_FILE_LEAVE) | shasum)" >> $ENV_AUTHORIZATION_FILE

The actual tests.

  $ cd .
  ENTERED: cwd:sub sub

  $ cd ..
  LEFT: cwd:sub cwd.t

  $ cd sub/sub2
  ENTERED: cwd:sub sub2
