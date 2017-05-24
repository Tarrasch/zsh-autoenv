[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/Tarrasch/zsh-autoenv/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

[![Build Status](https://travis-ci.org/Tarrasch/zsh-autoenv.svg?branch=master)](https://travis-ci.org/Tarrasch/zsh-autoenv)

# Autoenv for Zsh

zsh-autoenv automatically sources (known/whitelisted) `.autoenv.zsh` files,
typically used in project root directories.

It handles "enter" and leave" events, nesting, and stashing of
variables (overwriting and restoring).

## Features

 - Support for enter and leave events, which can use the same file.
   By default `.autoenv.zsh` is used for entering, and `.autoenv_leave.zsh`
   for leaving.
 - Interactively asks for confirmation / authentication before sourcing an
   unknown `.autoenv.zsh` file, and remembers whitelisted files by their
   hashed content.
 - Test suite.
 - Written in Zsh.

### Variable stashing

You can use `autostash` in your `.autoenv.zsh` files to overwrite some
variable, e.g.  `$PATH`.  When leaving the directory, it will be automatically
restored.

    % echo 'echo ENTERED; autostash FOO=changed' > project/.autoenv.zsh
    % FOO=orig
    % cd project
    Attempting to load unauthorized env file!
    -rw-rw-r-- 1 user user 36 Mai  6 20:38 /tmp/project/.autoenv.zsh

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


## Writing your .autoenv.zsh file

### `autoenv_source_parent()`

zsh-autoenv will stop looking for `.autoenv.zsh` files upwards after the first
one has been found, but you can use the function `autoenv_source_parent` to
source the next `.autoenv.zsh` file upwards the directory tree from there.

The function accepts an optional argument, which allows to stop looking before
the file system root is reached:

```zsh
autoenv_source_parent ../..
```

## Installation

Clone the repository and source it from your `~/.zshrc` file:

    % git clone https://github.com/Tarrasch/zsh-autoenv ~/.dotfiles/lib/zsh-autoenv
    % echo 'source ~/.dotfiles/lib/zsh-autoenv/autoenv.zsh' >> ~/.zshrc

### Using [antigen](https://github.com/zsh-users/antigen)

    antigen-bundle Tarrasch/zsh-autoenv

### Using [zgen](https://github.com/tarjoilija/zgen)

Add the following to your `.zshrc` where you are loading your plugins:

    zgen load Tarrasch/zsh-autoenv

### Using [zplug](https://github.com/zplug/zplug)

Add the following to your `.zshrc` where you are loading your plugins:

    zplug "Tarrasch/zsh-autoenv"

## Configuration

You can use the following variables to control zsh-autoenv's behavior.
Add them to your `~/.zshrc` file, before sourcing/loading zsh-autoenv.

### AUTOENV\_FILE\_ENTER
Name of the file to look for when entering directories.

Default: `.autoenv.zsh`

### AUTOENV\_FILE\_LEAVE
Name of the file to look for when leaving directories.
Requires `AUTOENV_HANDLE_LEAVE=1`.

Default: `.autoenv_leave.zsh`

### AUTOENV\_LOOK\_UPWARDS
Look for zsh-autoenv "enter" files in parent dirs?

Default: `1`

### AUTOENV\_HANDLE\_LEAVE
Handle leave events when changing away from a subtree, where an "enter"
event was handled?

Default: `1`

### AUTOENV\_DISABLED
(Temporarily) disable zsh-autoenv. This gets looked at in the chpwd handler.

Default: 0

### AUTOENV\_DEBUG
Enable debugging. Multiple levels are supported (max 2).

- 0: no debug messages
- 1: generic debug logging
- 2: more verbose messages
  - messages about adding/removing files on the internal stack
- 3: everything
  - sets xtrace option (`set -x`) while sourcing env files

Default: `0`

## Recipes

### Automatically activate Python virtualenvs

Given `AUTOENV_FILE_ENTER=.autoenv.zsh`, `AUTOENV_FILE_LEAVE=.autoenv.zsh` and
`AUTOENV_HANDLE_LEAVE=1` the following script will activate Python virtualenvs
automatically in all subdirectories (`.venv` directories get used by
[pipenv](https://github.com/kennethreitz/pipenv) with
`PIPENV_VENV_IN_PROJECT=1`):

```zsh
# Environment file for all projects.
#  - (de)activates Python virtualenvs (.venv) from pipenv

if [[ $autoenv_event == 'enter' ]]; then
  autoenv_source_parent

  _my_autoenv_venv_chpwd() {
    if [[ -z "$_ZSH_ACTIVATED_VIRTUALENV" && -n "$VIRTUAL_ENV" ]]; then
      return
    fi

    setopt localoptions extendedglob
    local -a venv
    venv=(./(../)#.venv(NY1:A))

    if [[ -n "$_ZSH_ACTIVATED_VIRTUALENV" && -n "$VIRTUAL_ENV" ]]; then
      if ! (( $#venv )) || [[ "$_ZSH_ACTIVATED_VIRTUALENV" != "$venv[1]" ]]; then
        unset _ZSH_ACTIVATED_VIRTUALENV
        echo "De-activating virtualenv: ${(D)VIRTUAL_ENV}" >&2
        deactivate
      fi
    fi

    if [[ -z "$VIRTUAL_ENV" ]]; then
      if (( $#venv )); then
        echo "Activating virtualenv: ${(D)venv}" >&2
        source $venv[1]/bin/activate
        _ZSH_ACTIVATED_VIRTUALENV="$venv[1]"
      fi
    fi
  }
  autoload -U add-zsh-hook
  add-zsh-hook chpwd _my_autoenv_venv_chpwd
  _my_autoenv_venv_chpwd
else
  add-zsh-hook -d chpwd _my_autoenv_venv_chpwd
fi
```

## Related projects
- https://github.com/direnv/direnv
- https://github.com/cxreg/smartcd
- https://github.com/kennethreitz/autoenv


## History

This started as an optimized version of the bash plugin
[autoenv](https://github.com/kennethreitz/autoenv) but for Zsh, and grew a lot
of functionality on top of it (inspired by [smartcd]).

The code was initially based on
[@joshuaclayton](https://github.com/joshuaclayton)'s dotfiles.
In September 2013 [@Tarrasch](https://github.com/Tarrasch) packaged it into a
nice [antigen]-compatible unit with integration tests. Since November 2014,
[@blueyed](https://github.com/blueyed) took over and added many many nice
features, mainly inspired by [smartcd].

[antigen]: https://github.com/Tarrasch/antigen-hs
[smartcd]: https://github.com/cxreg/smartcd
