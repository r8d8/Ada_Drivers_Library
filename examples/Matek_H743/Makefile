# Makefile for Ada Drivers Library Examples
# Uses Alire-managed toolchain

SHELL := /bin/bash
ALR_ENV := eval "$$(cd ../bb-runtimes && alr printenv --unix 2>/dev/null)"

.PHONY: all build clean

build:
	@$(ALR_ENV) && gprbuild -p -P *.gpr

clean:
	@$(ALR_ENV) && gprclean -P *.gpr || rm -rf obj

all: build
