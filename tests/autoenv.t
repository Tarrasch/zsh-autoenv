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
  $ _autoenv_read_answer() { echo 'y' }
  $ cd .
  Attempting to load unauthorized env file: /tmp/cramtests-??????/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? [y/N] 
  ENTERED





The last "ENTERED" is because it executed the command

Now lets see that it actually checks the shasum value

  $ unset _autoenv_stack_entered
  $ cd .
  ENTERED

  $ unset _autoenv_stack_entered
  $ rm $AUTOENV_ENV_FILENAME
  $ test_autoenv_add_to_env $PWD/.env mischief
  $ cd .
  Attempting to load unauthorized env file: /tmp/cramtests-??????/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? [y/N] 
  ENTERED





Now, will it take no for an answer?

  $ unset _autoenv_stack_entered
  $ rm $AUTOENV_ENV_FILENAME
  $ _autoenv_read_answer() { echo 'n' }
  $ cd .
  Attempting to load unauthorized env file: /tmp/cramtests-??????/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? [y/N] 





Lets also try one more time to ensure it didnt add it

  $ cd .
  Attempting to load unauthorized env file: /tmp/cramtests-??????/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? [y/N] 
