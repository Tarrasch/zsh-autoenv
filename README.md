[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/Tarrasch/zsh-autoenv/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

[![Build Status](https://travis-ci.org/Tarrasch/zsh-autoenv.svg?branch=master)](https://travis-ci.org/Tarrasch/zsh-autoenv)

# Autoenv for Zsh

zsh-autoenv automatically sources `.env` files, typically used in project
root directories.

It handles "enter" and leave" events, nesting, and stashing of
variables (overwriting and restoring).

## Features

 - Support for enter and leave events, which can use the same file.
   By default `.env` is used for entering, and `.env_leave` for leaving.
 - Asks for confirmation / authentication before sourcing a `.env` file, and
   remembers whitelisted files by its hash.
 - Test suite.
 - Written in Zsh.

### Variable stashing

You can use `autostash` in your `.env` files to overwrite some variable, e.g.
`$PATH`.  When leaving the directory, it will be automatically restored.

    % echo 'echo ENTERED; autostash FOO=changed' > project/.env
    % FOO=orig
    % cd project
    Attempting to load unauthorized env file!
    -rw-rw-r-- 1 user user 36 Mai  6 20:38 /tmp/project/.env

    **********************************************

    echo ENTERED; autostash FOO=changed

    **********************************************

    Would you like to authorize it? (type 'yes') yes
    ENTERED
    project % echo $FOO
    changed
    % cd ..
    % echo $FOO
    orig

There is also `stash`, `unstash` and `autounstash`, in case you want to
have more control.

The varstash library has been taken from smartcd, and was optimized for Zsh.


## Writing your .env file

### `autoenv_source_parent()`

zsh-autoenv will stop looking for `.env` files after the first one has been
found.  But you can use the function `autoenv_source_parent` to source a
parent `.env` file from there.


## Installation

Clone the repository and source it from your `~/.zshrc` file:

    % git clone https://github.com/Tarrasch/zsh-autoenv ~/.dotfiles/lib/zsh-autoenv
    % echo 'source ~/.dotfiles/lib/zsh-autoenv/autoenv.zsh' >> ~/.zshrc

### Using [antigen](https://github.com/zsh-users/antigen)

    antigen-bundle Tarrasch/zsh-autoenv

### Using [zgen](https://github.com/tarjoilija/zgen)

Add the following to your `.zshrc` where you are loading your plugins:

    zgen load Tarrasch/zsh-autoenv


## Configuration

You can use the following variables to control zsh-autoenv's behavior.
Add them to your `~/.zshrc` file, before sourcing/loading zsh-autoenv.

### AUTOENV\_FILE\_ENTER
Name of the file to look for when entering directories.

Default: `.env`

### AUTOENV\_FILE\_LEAVE
Name of the file to look for when leaving directories.
Requires `AUTOENV_HANDLE_LEAVE=1`.

Default: `.env_leave`

### AUTOENV\_LOOK\_UPWARDS
Look for .env files in parent dirs?

Default: `1`

### AUTOENV\_HANDLE\_LEAVE
Handle leave events when changing away from a subtree, where an "enter"
event was handled?

Default: `1`

### AUTOENV\_DISABLED
(Temporarily) disable zsh-autoenv. This gets looked at in the chpwd handler.

Default: 0

### `AUTOENV_DEBUG`
Enable debugging. Multiple levels are supported (max 2).

Default: `0`


## Related projects
- https://github.com/cxreg/smartcd
- https://github.com/kennethreitz/autoenv


## History

This started as a optimized version of
[autoenv](https://github.com/kennethreitz/autoenv) for Zsh, but grew a lot of
functionality on top of it (inspired by
[smartcd](https://github.com/cxreg/smartcd)).

The code was initially based on [Joshua Clayton](https://github.com/joshuaclayton)'s work.
