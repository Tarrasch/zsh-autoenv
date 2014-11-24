Test recursing into parent .env files.

  $ source $TESTDIR/setup.sh

Setup env actions / output.

  $ AUTOENV_LOOK_UPWARDS=1

Create env files in root dir.

  $ echo 'echo ENTERED_root: PWD:${PWD:t} from:${_autoenv_from_dir:t} to:${_autoenv_to_dir:t}' > .env
  $ echo 'echo LEFT_root: PWD:${PWD:t} from:${_autoenv_from_dir:t} to:${_autoenv_to_dir:t}' > .env.leave
  $ test_autoenv_auth_env_files

Create env files in sub dir.

  $ mkdir -p sub/sub2
  $ cd sub
  ENTERED_root: PWD:sub from:recurse-upwards.t to:sub

  $ echo 'echo ENTERED_sub: PWD:${PWD:t} from:${_autoenv_from_dir:t} to:${_autoenv_to_dir:t}' > .env
  $ echo 'echo LEFT_sub: PWD:${PWD:t} from:${_autoenv_from_dir:t} to:${_autoenv_to_dir:t}' > .env.leave
  $ test_autoenv_auth_env_files

The actual tests.

  $ cd .
  ENTERED_sub: PWD:sub from:sub to:sub

  $ cd ..
  LEFT_sub: PWD:sub from:sub to:recurse-upwards.t

  $ cd sub/sub2
  ENTERED_sub: PWD:sub2 from:recurse-upwards.t to:sub2

  $ cd ..

Changing the .env file should re-source it.

  $ echo 'echo ENTER2' >> .env

Set timestamp of auth file into the past, so it gets seen as new below.

  $ touch -t 201401010101 .env

  $ test_autoenv_auth_env_files
  $ cd .
  ENTERED_sub: PWD:sub from:sub to:sub
  ENTER2

Add sub/sub2/.env file, with a call to autoenv_source_parent.

  $ echo -e "echo autoenv_source_parent_from_sub2:\nautoenv_source_parent\necho done_sub2\n" > sub2/.env
  $ test_autoenv_add_to_env sub2/.env
  $ cd sub2
  autoenv_source_parent_from_sub2:
  ENTERED_sub: PWD:sub from:sub to:sub2
  ENTER2
  done_sub2

Move sub/.env away, now the root .env file should get sourced.

  $ mv ../.env ../.env.out
  $ touch -t 201401010102 .env
  $ cd .
  autoenv_source_parent_from_sub2:
  ENTERED_root: PWD:recurse-upwards.t from:sub2 to:sub2
  done_sub2
  $ mv ../.env.out ../.env

Prepend call to autoenv_source_parent to sub/.env file.

  $ cd ..
  $ echo -e "echo autoenv_source_parent_from_sub:\nautoenv_source_parent\n$(< .env)\necho done_sub" > .env
  $ touch -t 201401010103 .env
  $ test_autoenv_auth_env_files

  $ cd .
  autoenv_source_parent_from_sub:
  ENTERED_root: PWD:recurse-upwards.t from:sub to:sub
  ENTERED_sub: PWD:sub from:sub to:sub
  ENTER2
  done_sub


Add sub/sub2/.env file.

  $ echo -e "echo autoenv_source_parent_from_sub2:\nautoenv_source_parent\necho done_sub2\n" > sub2/.env
  $ test_autoenv_add_to_env sub2/.env
  $ cd sub2
  autoenv_source_parent_from_sub2:
  autoenv_source_parent_from_sub:
  ENTERED_root: PWD:recurse-upwards.t from:sub to:sub
  ENTERED_sub: PWD:sub from:sub to:sub
  ENTER2
  done_sub
  done_sub2

Go to root.

  $ cd ../..
  LEFT_sub: PWD:sub from:sub2 to:recurse-upwards.t
  ENTERED_root: PWD:recurse-upwards.t from:sub2 to:recurse-upwards.t


Changing the root .env should trigger re-authentication via autoenv_source_parent.

First, let's answer "no".

  $ echo "echo NEW" > .env
  $ _autoenv_read_answer() { echo 'n' }
  $ cd sub
  autoenv_source_parent_from_sub:
  Attempting to load unauthorized env file: /tmp/cramtests-*/recurse-upwards.t/.env (glob)
  
  **********************************************
  
  echo NEW
  
  **********************************************
  
  Would you like to authorize it? [y/N] 
  ENTERED_sub: PWD:sub from:recurse-upwards.t to:sub
  ENTER2
  done_sub

Now with "yes".
This currently does not trigger re-execution of the .env file.

  $ _autoenv_read_answer() { echo 'y' }
  $ cd .

Touching the .env file will now source the parent env file.

  $ touch -t 201401010104 .env
  $ cd .
  autoenv_source_parent_from_sub:
  Attempting to load unauthorized env file: /tmp/cramtests-*/recurse-upwards.t/.env (glob)
  
  **********************************************
  
  echo NEW
  
  **********************************************
  
  Would you like to authorize it? [y/N] 
  NEW
  ENTERED_sub: PWD:sub from:sub to:sub
  ENTER2
  done_sub
