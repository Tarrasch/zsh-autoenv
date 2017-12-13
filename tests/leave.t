  $ source $TESTDIR/setup.zsh || return 1

Lets set a simple .autoenv.zsh action

  $ mkdir sub
  $ cd sub
  $ echo 'echo ENTERED' > .autoenv.zsh
  $ echo 'echo LEFT' > .autoenv_leave.zsh

Change to the directory.

  $ _autoenv_ask_for_yes() { echo "yes"; return 0 }
  $ cd .
  Attempting to load unauthorized env file!
  -* /*/cramtests-*/leave.t/sub/.autoenv.zsh (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') yes
  ENTERED


Leave the directory and answer "no".

  $ _autoenv_ask_for_yes() { echo "no"; return 1 }
  $ cd ..
  Attempting to load unauthorized env file!
  -* /*/cramtests-*/leave.t/sub/.autoenv_leave.zsh (glob)
  
  **********************************************
  
  echo LEFT
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') no


  $ cd sub
  ENTERED
  $ _autoenv_ask_for_yes() { echo "yes"; return 0 }
  $ cd ..
  Attempting to load unauthorized env file!
  -* /*/cramtests-*/leave.t/sub/.autoenv_leave.zsh (glob)
  
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


Test that .autoenv.zsh is sourced only once with AUTOENV_HANDLE_LEAVE=0.

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
  $ echo 'echo ENTERED outside: PWD:${PWD:t} pwd:${${"$(pwd)"}:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t} event:${autoenv_event}' > .autoenv.zsh
  $ echo 'echo LEFT outside: PWD:${PWD:t} pwd:${${"$(pwd)"}:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t} event:${autoenv_event}' > .autoenv_leave.zsh
  $ echo 'echo LEFT: autoenv_env_file:${autoenv_env_file}' >> .autoenv_leave.zsh
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
  LEFT: autoenv_env_file:*/leave.t/sub/symlink/.autoenv_leave.zsh (glob)
  $ cd sub/symlink
  ENTERED outside: PWD:symlink pwd:symlink from:leave.t to:symlink event:enter

$autoenv_env_file should not be exported.

  $ echo -n $autoenv_env_file

$autoenv_env_file should be reset when leaving.

  $ echo -n $autoenv_env_file
  $ cd ../..
  LEFT outside: PWD:leave.t pwd:leave.t from:symlink to:leave.t event:leave
  LEFT: autoenv_env_file:*/leave.t/sub/symlink/.autoenv_leave.zsh (glob)
  $ echo ${autoenv_env_file:-empty}
  empty
