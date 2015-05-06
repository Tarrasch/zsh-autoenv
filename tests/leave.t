  $ source $TESTDIR/setup.zsh || return 1

Lets set a simple .env action

  $ mkdir sub
  $ cd sub
  $ echo 'echo ENTERED' > .env
  $ echo 'echo LEFT' > .env_leave

Change to the directory.

  $ _autoenv_ask_for_yes() { echo "yes"; return 0 }
  $ cd .
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/leave.t/sub/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') yes
  ENTERED


Leave the directory and answer "no".

  $ _autoenv_ask_for_yes() { echo "no"; return 1 }
  $ cd ..
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/leave.t/sub/.env_leave (glob)
  
  **********************************************
  
  echo LEFT
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') no


  $ cd sub
  ENTERED
  $ _autoenv_ask_for_yes() { echo "yes"; return 0 }
  $ cd ..
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/leave.t/sub/.env_leave (glob)
  
  **********************************************
  
  echo LEFT
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') yes
  LEFT


Now check with subdirs, looking upwards.

  $ AUTOENV_LOOK_UPWARDS=1
  $ mkdir sub/child
  $ cd sub/child
  ENTERED
  $ cd .
  $ cd ..
  $ cd ..
  LEFT


Now check with subdirs, not looking at parent dirs.

  $ AUTOENV_LOOK_UPWARDS=0
  $ cd sub/child
  $ cd ..
  ENTERED
  $ cd child
  $ cd ../..
  LEFT


Test that .env is sourced only once with AUTOENV_HANDLE_LEAVE=0.

  $ unset _autoenv_stack_entered
  $ AUTOENV_HANDLE_LEAVE=0
  $ cd sub
  ENTERED
  $ cd ..
  $ cd sub


Test that "leave" is not triggered when entering an outside dir via symlink.

  $ AUTOENV_HANDLE_LEAVE=1
  $ cd ..
  LEFT
  $ mkdir outside
  $ cd outside
  $ echo 'echo ENTERED outside: PWD:${PWD:t} pwd:${${"$(pwd)"}:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t} event:${autoenv_event}' > .env
  $ echo 'echo LEFT outside: PWD:${PWD:t} pwd:${${"$(pwd)"}:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t} event:${autoenv_event}' > .env_leave
  $ test_autoenv_auth_env_files

  $ cd ..
  $ ln -s ../outside sub/symlink
  $ cd sub
  ENTERED
  $ cd symlink
  ENTERED outside: PWD:symlink pwd:symlink from:sub to:symlink event:enter

  $ cd ../..
  LEFT
  LEFT outside: PWD:leave.t pwd:leave.t from:symlink to:leave.t event:leave
  $ cd sub/symlink
  ENTERED outside: PWD:symlink pwd:symlink from:leave.t to:symlink event:enter

$autoenv_env_file should be reset when leaving.

  $ echo $autoenv_env_file
  */leave.t/sub/symlink/.env (glob)
  $ cd ../..
  LEFT outside: PWD:leave.t pwd:leave.t from:symlink to:leave.t event:leave
  $ echo ${autoenv_env_file:-empty}
  empty
