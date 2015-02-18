[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/Tarrasch/zsh-autoenv/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

[![Build Status](https://travis-ci.org/Tarrasch/zsh-autoenv.svg?branch=master)](https://travis-ci.org/Tarrasch/zsh-autoenv)

# Autoenv for zsh

This is is a zsh optimized version of
[autoenv](https://github.com/kennethreitz/autoenv)

## Why a zsh version

  * Auto-completion will work rather than vomit
  * No stupid error messages
  * It's elegant to use the built in `chpwd_functions`

## Installation

### Using [antigen](https://github.com/zsh-users/antigen)

    antigen-bundle Tarrasch/zsh-autoenv

### Using [zgen](https://github.com/tarjoilija/zgen)

Add

    zgen load Tarrasch/zsh-autoenv

to your `.zshrc` where you're loading your other plugins.

### Manually

Clone the repository and source it from your `~/.zshrc` file:

    git clone https://github.com/Tarrasch/zsh-autoenv ~/.dotfiles/lib/zsh-autoenv
    echo 'source ~/.dotfiles/lib/zsh-autoenv/autoenv.zsh' >> ~/.zshrc

## Credits

The code was mostly copied from [Joshua Clayton](https://github.com/joshuaclayton)
