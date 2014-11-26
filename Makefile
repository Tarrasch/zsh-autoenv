.PHONY: itest test

test:
	ZDOTDIR="${PWD}/tests" cram --shell=zsh -v tests

itest:
	ZDOTDIR="${PWD}/tests" cram -i --shell=zsh tests

# Define targets for test files, with relative and abolute path.
# Use verbose output, which is useful with Vim's 'errorformat'.
TESTS:=$(wildcard tests/*.t)

uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
_TESTS_REL_AND_ABS:=$(call uniq,$(abspath $(TESTS)) $(TESTS))
$(_TESTS_REL_AND_ABS):
	ZDOTDIR="${PWD}/tests" cram --shell=zsh -v $@
.PHONY: $(_TESTS_REL_AND_ABS)
