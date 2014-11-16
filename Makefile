.PHONY: itest test

itest:
	ZDOTDIR="${PWD}/tests" cram -i --shell=zsh tests

test:
	ZDOTDIR="${PWD}/tests" cram --shell=zsh tests
