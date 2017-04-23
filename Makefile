# Default, can be overridden using "make test ZDOTDIR=...".
ZDOTDIR:=${CURDIR}/tests/ZDOTDIR

# Export it, and make it absolute.
override export ZDOTDIR:=$(abspath $(ZDOTDIR))

TEST_SHELL:=zsh

test:
	$(TEST_SHELL) --version
	cram --debug --shell=$(TEST_SHELL) tests

itest:
	cram -i --shell=$(TEST_SHELL) tests

# Run tests with all ZDOTDIRs.
test_full:
	$(TEST_SHELL) --version
	ret=0; \
	for i in $(wildcard tests/ZDOTDIR*); do \
		echo "== ZDOTDIR=$$i =="; \
		$(MAKE) test TEST_SHELL=$(TEST_SHELL) ZDOTDIR=${CURDIR}/$$i || ret=$$((ret+1)); \
		echo; \
	done; \
	exit $$ret

# Define targets for test files, with relative and abolute path.
# Use verbose output, which is useful with Vim's 'errorformat'.
TESTS:=$(wildcard tests/*.t)

uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
_TESTS_REL_AND_ABS:=$(call uniq,$(abspath $(TESTS)) $(TESTS))
$(_TESTS_REL_AND_ABS):
	cram --shell=$(TEST_SHELL) -v $@
.PHONY: $(_TESTS_REL_AND_ABS)

.PHONY: itest test

clean:
	$(RM) tests/*.err
