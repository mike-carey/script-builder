#!/bin/bash

export __BASE_DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
export __TEST_DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

export __OUTPUT__="$__TEST_DIR__"/_output

mkdir -p "$__OUTPUT__"

mock._log() {
  echo "[MOCK] ${@}"
}

###
# Initializes the MOCKDIR for creating extra directories and files
##
mock.init() {
  local _mock_dir="$(mktemp -d -t mock)"

  export __MOCKDIR__="$__OUTPUT__"/"${_mock_dir/$TMPDIR/}"

  mv "$_mock_dir" "$__MOCKDIR__"
  mock._log "Created mock directory: $__MOCKDIR__"
}

###
# Creates a directory under the current `MOCKDIR`
##
mock.dir() {
  local _dir="$1"
  local _filename="$2"

  export MOCKDIR="$__MOCKDIR__"/"$_dir"

  mkdir -p "$MOCKDIR"
  if [ ! -z "$_filename" ]; then
    export MOCKFILE="$MOCKDIR"/"$_filename"

    mock._log "Created file: $MOCKFILE"
    touch "$MOCKFILE"
  fi
}

mock.bin() {
  mock.dir bin "$1"
}

mock.lib() {
  mock.dir lib "$1"
}

mock.man() {
  mock.dir man "$1"
}

mock.util() {
  mock.dir util "$1"
}

mock.deinit() {
  unset __MOCKDIR__
}

export -f mock._log \
          mock.init \
          mock.dir \
          mock.bin \
          mock.lib \
          mock.man \
          mock.util \
          mock.deinit

# test.mock
