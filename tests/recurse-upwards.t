Test recursing into parent .autoenv.zsh files.

  $ source $TESTDIR/setup.zsh || return 1

Setup env actions / output.

  $ AUTOENV_LOOK_UPWARDS=1

Create env files in root dir.

  $ echo 'echo ENTERED_root: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv.zsh
  $ echo 'echo LEFT_root: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv_leave.zsh
  $ test_autoenv_auth_env_files

Create env files in sub dir.

  $ mkdir -p sub/sub2
  $ cd sub
  ENTERED_root: PWD:sub from:recurse-upwards.t to:sub

  $ echo 'echo ENTERED_sub: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv.zsh
  $ echo 'echo LEFT_sub: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv_leave.zsh
  $ test_autoenv_auth_env_files

The actual tests.

  $ cd .
  ENTERED_sub: PWD:sub from:sub to:sub

  $ cd ..
  LEFT_sub: PWD:recurse-upwards.t from:sub to:recurse-upwards.t

  $ cd sub/sub2
  ENTERED_sub: PWD:sub2 from:recurse-upwards.t to:sub2

  $ cd ..

Changing the .autoenv.zsh file should re-source it.

  $ echo 'echo ENTER2' >> .autoenv.zsh

Set timestamp of auth file into the past, so it gets seen as new below.

  $ touch -t 201401010101 .autoenv.zsh

  $ test_autoenv_auth_env_files
  $ cd .
  ENTERED_sub: PWD:sub from:sub to:sub
  ENTER2

Add sub/sub2/.autoenv.zsh file, with a call to autoenv_source_parent.

  $ echo "echo autoenv_source_parent_from_sub2:\nautoenv_source_parent\necho done_sub2\n" > sub2/.autoenv.zsh
  $ test_autoenv_add_to_env sub2/.autoenv.zsh
  $ cd sub2
  autoenv_source_parent_from_sub2:
  ENTERED_sub: PWD:sub2 from:sub to:sub2
  ENTER2
  done_sub2

Move sub/.autoenv.zsh away, now the root .autoenv.zsh file should get sourced.

  $ mv ../.autoenv.zsh ../.autoenv.zsh.out
  $ touch -t 201401010102 .autoenv.zsh
  $ cd .
  autoenv_source_parent_from_sub2:
  ENTERED_root: PWD:sub2 from:sub2 to:sub2
  done_sub2
  $ mv ../.autoenv.zsh.out ../.autoenv.zsh

Prepend call to autoenv_source_parent to sub/.autoenv.zsh file.

  $ cd ..
  $ echo -e "echo autoenv_source_parent_from_sub:\nautoenv_source_parent\n$(cat .autoenv.zsh)" >| .autoenv.zsh
  $ echo "echo done_sub" >> .autoenv.zsh
  $ touch -t 201401010103 .autoenv.zsh
  $ test_autoenv_auth_env_files

  $ cd .
  autoenv_source_parent_from_sub:
  ENTERED_root: PWD:sub from:sub to:sub
  ENTERED_sub: PWD:sub from:sub to:sub
  ENTER2
  done_sub


Add sub/sub2/.autoenv.zsh file.

  $ echo -e "echo autoenv_source_parent_from_sub2:\nautoenv_source_parent\necho done_sub2\n" >| sub2/.autoenv.zsh
  $ test_autoenv_add_to_env sub2/.autoenv.zsh
  $ cd sub2
  autoenv_source_parent_from_sub2:
  autoenv_source_parent_from_sub:
  ENTERED_root: PWD:sub2 from:sub to:sub2
  ENTERED_sub: PWD:sub2 from:sub to:sub2
  ENTER2
  done_sub
  done_sub2

Go to root.
This should not trigger the enter event, because it was handled via
autoenv_source_parent already.

  $ cd ../..
  LEFT_sub: PWD:recurse-upwards.t from:sub2 to:recurse-upwards.t


Changing the root .autoenv.zsh should trigger re-authentication via
autoenv_source_parent.

First, let's answer "no".

  $ echo "echo NEW" >| .autoenv.zsh
  $ _autoenv_ask_for_yes() { echo "no"; return 1 }
  $ cd sub
  autoenv_source_parent_from_sub:
  Attempting to load unauthorized env file!
  -* /*/cramtests-*/recurse-upwards.t/.autoenv.zsh (glob)
  
  **********************************************
  
  echo NEW
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') no
  ENTERED_sub: PWD:sub from:recurse-upwards.t to:sub
  ENTER2
  done_sub

Now with "yes".
This currently does not trigger re-execution of the .autoenv.zsh file.

  $ _autoenv_ask_for_yes() { echo "yes"; return 0 }
  $ cd .

Touching the .autoenv.zsh file will now source the parent env file.

  $ touch -t 201401010104 .autoenv.zsh
  $ cd .
  autoenv_source_parent_from_sub:
  Attempting to load unauthorized env file!
  -* /*/cramtests-*/recurse-upwards.t/.autoenv.zsh (glob)
  
  **********************************************
  
  echo NEW
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') yes
  NEW
  ENTERED_sub: PWD:sub from:sub to:sub
  ENTER2
  done_sub


  $ cd ..
  LEFT_sub: PWD:recurse-upwards.t from:sub to:recurse-upwards.t
  $ mkdir sub/sub2/sub3
  $ cd sub/sub2/sub3
  autoenv_source_parent_from_sub2:
  autoenv_source_parent_from_sub:
  NEW
  ENTERED_sub: PWD:sub3 from:recurse-upwards.t to:sub3
  ENTER2
  done_sub
  done_sub2
