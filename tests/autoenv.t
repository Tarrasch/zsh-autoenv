  $ source $TESTDIR/setup.sh

Lets set a simple .env action

  $ echo 'echo ENTERED' >> .env

Manually create auth file

  $ test_autoenv_add_to_env $PWD/.env
  $ cd .
  ENTERED

Now try to make it accept it

  $ unset _autoenv_stack_entered
  $ rm $AUTOENV_ENV_FILENAME
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

  $ unset _autoenv_stack_entered
  $ cd .
  ENTERED

  $ unset _autoenv_stack_entered
  $ rm $AUTOENV_ENV_FILENAME
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

  $ unset _autoenv_stack_entered
  $ rm $AUTOENV_ENV_FILENAME
  $ _autoenv_ask_for_yes() { echo "no"; return 1 }
  $ cd .
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') no


Lets also try one more time to ensure it didn't add it.

  $ cd .
  Attempting to load unauthorized env file!
  -* /tmp/cramtests-*/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') no
