#!/bin/bash

TEST=test
VENDOR=vendor

util.test() {
  "$VENDOR"/.bin/bash-unit $( find "$TEST" -name "${1:-test_*.sh}" )
}

if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  echo "Cannot run this via source.  Please run build as a file" >&2
  exit 255
else
  util.test "${@}"
  exit $?
fi

# util.setup
