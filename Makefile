export ZDOTDIR=${CURDIR}/tests/ZDOTDIR

test:
	cram --shell=zsh -v tests

itest:
	cram -i --shell=zsh tests

# Run tests with all ZDOTDIRs.
test_full:
	for i in $(wildcard tests/ZDOTDIR*); do \
		echo "ZDOTDIR=$$i"; \
		ZDOTDIR=${CURDIR}/$$i cram --shell=zsh -v tests; \
		echo; \
	done

# Define targets for test files, with relative and abolute path.
# Use verbose output, which is useful with Vim's 'errorformat'.
TESTS:=$(wildcard tests/*.t)

uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
_TESTS_REL_AND_ABS:=$(call uniq,$(abspath $(TESTS)) $(TESTS))
$(_TESTS_REL_AND_ABS):
	cram --shell=zsh -v $@
.PHONY: $(_TESTS_REL_AND_ABS)

.PHONY: itest test

clean:
	$(RM) tests/*.err
