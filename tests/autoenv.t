  $ source $TESTDIR/setup.zsh || return 1

Lets set a simple .autoenv.zsh action

  $ echo 'echo ENTERED' > .autoenv.zsh

Manually create auth file

  $ test_autoenv_add_to_env $PWD/.autoenv.zsh
  $ cd .
  ENTERED

Now try to make it accept it

  $ _autoenv_stack_entered=()
  $ rm $AUTOENV_AUTH_FILE
  $ _autoenv_ask_for_yes() { echo "yes" }
  $ cd .
  Attempting to load unauthorized env file!
  -* /*/cramtests-*/autoenv.t/.autoenv.zsh (glob)
  
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

  $ _autoenv_stack_entered=()
  $ rm $AUTOENV_AUTH_FILE
  $ test_autoenv_add_to_env $PWD/.autoenv.zsh mischief
  $ cd .
  Attempting to load unauthorized env file!
  -* /*/cramtests-*/autoenv.t/.autoenv.zsh (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') yes
  ENTERED


Now, will it take no for an answer?

  $ _autoenv_stack_entered=()
  $ rm $AUTOENV_AUTH_FILE
  $ _autoenv_ask_for_yes() { echo "no"; return 1 }
  $ cd .
  Attempting to load unauthorized env file!
  -* /*/cramtests-*/autoenv.t/.autoenv.zsh (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') no


Lets also try one more time to ensure it didn't add it.

  $ _autoenv_ask_for_yes() { echo "yes"; return 0 }
  $ cd .
  Attempting to load unauthorized env file!
  -* /*/cramtests-*/autoenv.t/.autoenv.zsh (glob)
  
  **********************************************
  
  echo ENTERED
  
  **********************************************
  
  Would you like to authorize it? (type 'yes') yes
  ENTERED

Reloading the script should keep the current state, e.g. when reloading your
~/.zshrc.

  $ $TEST_SOURCE_AUTOENV
  $ cd .
