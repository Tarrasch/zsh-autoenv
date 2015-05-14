  $ source $TESTDIR/setup.zsh || return 1

Lets set a simple .env action

  $ echo 'echo ENTERED' > .env

Manually create auth file

  $ test_autoenv_add_to_env $PWD/.env
  $ cd .
  ENTERED

Now try to make it accept it

  $ _autoenv_stack_entered=()
  $ rm $AUTOENV_ENV_FILENAME
  $ _autoenv_asked_already=()
  $ _autoenv_ask_for_yes() { echo "yes" }
  $ cd .
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') yes
  ENTERED


The last "ENTERED" is because it executed the command.

Now lets see that it actually checks the shasum value.

  $ _autoenv_stack_entered=()
  $ cd .
  ENTERED

  $ rm $AUTOENV_ENV_FILENAME
  $ _autoenv_stack_entered=()
  $ _autoenv_asked_already=()
  $ test_autoenv_add_to_env $PWD/.env mischief
  $ cd .
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') yes
  ENTERED


Now, will it take no for an answer?

  $ rm $AUTOENV_ENV_FILENAME
  $ _autoenv_stack_entered=()
  $ _autoenv_asked_already=()
  $ _autoenv_ask_for_yes() { echo "no"; return 1 }
  $ cd .
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') no


Lets also try one more time to ensure it didn't add it.

  $ _autoenv_asked_already=()
  $ _autoenv_ask_for_yes() { echo "no"; return 1 }
  $ cd .
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') no

And now see if we're not being asked again after not allowing it.

  $ _autoenv_ask_for_yes() { echo "should_not_be_used"; return 1 }
  $ cd .


Reloading the script should keep the current state, e.g. when reloading your
~/.zshrc.
But it should re-ask for unauthorized files.

  $ cd ..
  $ $TEST_SOURCE_AUTOENV
  $ _autoenv_ask_for_yes() { echo "yes"; return 0 }
  $ cd -
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') yes
  ENTERED

With an authorized file, it should not re-ask you.

  $ $TEST_SOURCE_AUTOENV
  $ cd .
