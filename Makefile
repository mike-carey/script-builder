###
# Project aliases
##

BIN = bin
DIST = dist
LIB = lib
TEST = test
VENDOR = vendor

VENDOR_BIN = $(VENDOR)/.bin

BASH_UNIT = $(VENDOR_BIN)/bash-unit

.PHONY: default bin help test vendor

# Make help default
default: help
.DEFAULT_GOAL := help

bin:
	@ $(LIB)/bin-builder.sh
# bin

help:
	@ echo "Usage: make <command> where command is one of the following:"
	@ echo "  bin         Creates links in bin for each lib script"
	@ echo "  help        Prints this message"
	@ echo "  test        Runs unit tests"
	@ echo "  vendor      Updates the submodules in the vendor directory"
	@ echo
# help

test:
	@ $(BASH_UNIT) test/test_*.sh
# test

vendor:
	@ git submodule update --init --remote --force --recursive --
# vendor

# builder
