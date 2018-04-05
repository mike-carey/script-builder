#!/bin/bash

TEST=test
VENDOR=vendor

util.test() {
  local _tests="$@"

  if [ -z "$_tests" ]; then
    _tests=$( find "$TEST" -name "${1:-test_*.sh}" )
  fi

  "$VENDOR"/.bin/bash-unit $_tests
}

if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  echo "Cannot run this via source.  Please run build as a file" >&2
  exit 255
else
  util.test "${@}"
  exit $?
fi

# util.setup
