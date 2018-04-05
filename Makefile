###
# Project aliases
##

UTIL = util

UTILS = $(shell echo $(wildcard $(UTIL)/*.sh) | sed 's/'$(UTIL)'\///g' | sed 's/.sh//g' )

.PHONY: default help *

# Make help default
default: help
.DEFAULT_GOAL := help

help:
	@ echo "Usage: make <command> where command is one of the following:"
	@ echo "  help        Prints this message"
	@ echo "  vendor      Updates the submodules in the vendor directory"
	@ for i in $(UTILS) ; do printf '  %-10s  %s\n' "$$i" "Runs the $(UTIL)/$$i.sh script"; done
	@ echo
# help

vendor:
	@ git submodule update --init --remote --force --recursive --
# vendor

$(UTILS):
ifeq (,$(wildcard $(UTIL)/$(@)))
	$(error Could not find proper util)
endif
	@ $(UTIL)/$(@).sh
# %

# builder
