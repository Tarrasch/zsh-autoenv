[![Build Status](https://travis-ci.org/Tarrasch/zsh-autoenv.svg?branch=master)](https://travis-ci.org/Tarrasch/zsh-autoenv)

# Autoenv for Zsh

zsh-autoenv automatically sources (known/whitelisted) `.autoenv.zsh` files,
typically used in project root directories.

It handles "enter" and leave" events, nesting, and stashing of
variables (overwriting and restoring).

## Requirements

- Zsh version 4.3.10 or later.

## Features

- Support for enter and leave events, which can use the same file.
  By default it uses `.autoenv.zsh` for entering, and `.autoenv_leave.zsh`
  for leaving.
- Interactively asks for confirmation / authentication before sourcing an
  unknown `.autoenv.zsh` file, and remembers whitelisted files by their
  hashed content.
- Test suite.
- Written in/for Zsh.

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

### AUTOENV_FILE_ENTER

Name of the file to look for when entering directories.

Default: `.autoenv.zsh`

### AUTOENV_FILE_LEAVE

Name of the file to look for when leaving directories.
Requires `AUTOENV_HANDLE_LEAVE=1`.

Default: `.autoenv_leave.zsh`

### AUTOENV_LOOK_UPWARDS

Look for zsh-autoenv "enter" files in parent dirs?

Default: `1`

### AUTOENV_HANDLE_LEAVE

Handle leave events when changing away from a subtree, where an "enter"
event was handled?

Default: `1`

### AUTOENV_DISABLED

(Temporarily) disable zsh-autoenv. This gets looked at in the chpwd handler.

Default: 0

### AUTOENV_DEBUG

Set debug level. If enabled (> 0) it will print information to stderr.

- 0: no debug messages
- 1: generic debug logging
- 2: more verbose messages
  - messages about adding/removing files on the internal stack
- 3: everything
  - sets xtrace option (`set -x`) while sourcing env files

Default: `0`

## Usage

zsh-autoenv works automatically once installed.

You can use ``autoenv-edit`` to edit the nearest/current autoenv files.
It will use ``$AUTOENV_EDITOR``, ``$EDITOR``, or ``vim`` for editing.

## Helper functions

The following helper functions are available:

### autoenv_append_path

Appends path(s) to `$path` (`$PATH`), if they are not in there already.

### autoenv_prepend_path

Prepends path(s) to `$path` (`$PATH`), if they are not in there already.

### autoenv_remove_path

Removes path(s) from `$path` (`$PATH`).

Returns 0 in case `$path` has changed, 1 otherwise.

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

        # Simulate "deactivate", but handle $PATH better (remove VIRTUAL_ENV).
        if ! autoenv_remove_path $VIRTUAL_ENV/bin; then
          echo "warning: ${VIRTUAL_ENV}/bin not found in \$PATH" >&2
        fi

        # NOTE: does not handle PYTHONHOME/_OLD_VIRTUAL_PYTHONHOME
        unset _OLD_VIRTUAL_PYTHONHOME
        # NOTE: does not handle PS1/_OLD_VIRTUAL_PS1
        unset _OLD_VIRTUAL_PS1
        unset VIRTUAL_ENV
      fi
    fi

    if [[ -z "$VIRTUAL_ENV" ]]; then
      if (( $#venv )); then
        echo "Activating virtualenv: ${(D)venv}" >&2
        export VIRTUAL_ENV=$venv[1]
        autoenv_prepend_path $VIRTUAL_ENV/bin
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

- <https://github.com/direnv/direnv>
- <https://github.com/cxreg/smartcd>
- <https://github.com/kennethreitz/autoenv>

## History

This started as an optimized version of the bash plugin
[autoenv](https://github.com/kennethreitz/autoenv) but for Zsh, and grew a lot
of functionality on top of it (inspired by [smartcd]).

The code was initially based on
[@joshuaclayton](https://github.com/joshuaclayton)'s dotfiles.
In September 2013 [@Tarrasch](https://github.com/Tarrasch) packaged it into a
nice [antigen]-compatible unit with integration tests. Since November 2014,
[@blueyed](https://github.com/blueyed) took over and added many nice
features, mainly inspired by [smartcd].

[antigen]: https://github.com/Tarrasch/antigen-hs
[smartcd]: https://github.com/cxreg/smartcd
