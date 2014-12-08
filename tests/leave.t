  $ source $TESTDIR/setup.sh

Lets set a simple .env action

  $ mkdir sub
  $ cd sub
  $ echo 'echo ENTERED' > .env
  $ echo 'echo LEFT' > .env.leave

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
  -* /tmp/cramtests-*/leave.t/sub/.env.leave (glob)
  
  **********************************************
  
  echo LEFT
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') no


  $ cd sub
  ENTERED
  $ _autoenv_ask_for_yes() { echo "yes"; return 0 }
  $ cd ..
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/leave.t/sub/.env.leave (glob)
  
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
