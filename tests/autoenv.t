Ensure we have our mocked out ENV_AUTHORIZATION_FILE

  $ [[ $ENV_AUTHORIZATION_FILE[0,4] == '/tmp' ]] || return 1

Lets set a simple .env action

  $ echo 'echo blah' >> .env

Manually create auth file

  $ echo "$PWD/.env:$(echo echo blah | shasum)" > $ENV_AUTHORIZATION_FILE
  $ cd .
  blah

Now try to make it accept it

  $ rm $ENV_AUTHORIZATION_FILE
  $ _dotenv_read_answer() { answer='y' }
  $ cd .
  Attempting to load unauthorized env: /tmp/cramtests-??????/autoenv.t/.env (glob)

  **********************************************

  echo blah

  **********************************************

  Would you like to authorize it? (y/n)
  blah

The last "blah" is because it executed the command

Now lets see that it actually checks the shasum value

  $ cd .
  blah
  $ rm $ENV_AUTHORIZATION_FILE
  $ echo "$PWD/.env:$(echo mischief | shasum)" > $ENV_AUTHORIZATION_FILE
  $ cd .
  Attempting to load unauthorized env: /tmp/cramtests-??????/autoenv.t/.env (glob)

  **********************************************

  echo blah

  **********************************************

  Would you like to authorize it? (y/n)
  blah

Now, will it take no for an answer?

  $ rm $ENV_AUTHORIZATION_FILE
  $ _dotenv_read_answer() { answer='n' }
  $ cd .
  Attempting to load unauthorized env: /tmp/cramtests-??????/autoenv.t/.env (glob)

  **********************************************

  echo blah

  **********************************************

  Would you like to authorize it? (y/n)

Lets also try one more time to ensure it didnt add it

  $ cd .
  Attempting to load unauthorized env: /tmp/cramtests-??????/autoenv.t/.env (glob)

  **********************************************

  echo blah

  **********************************************

  Would you like to authorize it? (y/n)
