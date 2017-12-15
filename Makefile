# Empty by default, can be overridden using "make test ZDOTDIR=…".
ZDOTDIR:=
# Make it absolute.
override ZDOTDIR:=$(abspath $(ZDOTDIR))

TEST_SHELL:=zsh

test:
	ZDOTDIR=$(ZDOTDIR) cram --shell=$(TEST_SHELL) -v tests

itest:
	ZDOTDIR=$(ZDOTDIR) cram -i --shell=$(TEST_SHELL) tests

# Run tests with all ZDOTDIRs.
test_full:
	@ret=0; \
	for i in $(wildcard tests/ZDOTDIR*); do \
	  echo "TEST_SHELL=$(TEST_SHELL) ZDOTDIR=$$i"; \
	  ZDOTDIR=${CURDIR}/$$i cram --shell=$(TEST_SHELL) -v tests || ret=$$?; \
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
