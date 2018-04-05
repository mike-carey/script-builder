#!/bin/bash

REMOTE=${REMOTE:-http://}

util.setup() {
  echo "Setting up"
}

if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  echo "Cannot run this via source.  Please run build as a file" >&2
  exit 255
else
  util.setup "${@}"
  exit $?
fi

# util.setup
