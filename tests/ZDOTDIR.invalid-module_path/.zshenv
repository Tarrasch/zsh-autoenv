# Use invalid module path for zsh, to test alternative zstat implementation.

# Pre-load zsh/parameter, where we do not have/need(?) an alternative
# implementation.
zmodload zsh/parameter

module_path=(/dev/null)

zstat() {
  echo "Should not get called."
}
