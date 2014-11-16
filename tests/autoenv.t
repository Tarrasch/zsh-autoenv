Ensure we have our mocked out ENV_AUTHORIZATION_FILE

  $ [[ $ENV_AUTHORIZATION_FILE[0,4] == '/tmp' ]] || return 1

Lets set a simple .env action

  $ echo 'echo ENTERED' >> .env

Manually create auth file

  $ echo "$PWD/.env:$(echo echo ENTERED | shasum)" > $ENV_AUTHORIZATION_FILE
  $ cd .
  ENTERED

Now try to make it accept it

  $ unset _dotenv_stack_entered
  $ rm $ENV_AUTHORIZATION_FILE
  $ _dotenv_read_answer() { echo 'y' }
  $ cd .
  Attempting to load unauthorized env file: /tmp/cramtests-??????/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? [y/N] 
  ENTERED





The last "ENTERED" is because it executed the command

Now lets see that it actually checks the shasum value

  $ unset _dotenv_stack_entered
  $ cd .
  ENTERED

  $ unset _dotenv_stack_entered
  $ rm $ENV_AUTHORIZATION_FILE
  $ echo "$PWD/.env:$(echo mischief | shasum)" > $ENV_AUTHORIZATION_FILE
  $ cd .
  Attempting to load unauthorized env file: /tmp/cramtests-??????/autoenv.t/.env (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? [y/N] 
  ENTERED





Now, will it take no for an answer?

  $ unset _dotenv_stack_entered
  $ rm $ENV_AUTHORIZATION_FILE
  $ _dotenv_read_answer() { echo 'n' }
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
