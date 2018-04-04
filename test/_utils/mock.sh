#!/bin/bash

export __BASE_DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
export __TEST_DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

export __OUTPUT__="$__TEST_DIR__"/_output

mkdir -p "$__OUTPUT__"

mock._log() {
  if [ ! -z ${MOCK_VERBOSE+x} ]; then
    echo "[MOCK] ${@}" >&2
  fi
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
  local _content="${@:3}"

  export MOCKDIR="$__MOCKDIR__"/"$_dir"

  mkdir -p "$MOCKDIR"
  if [ ! -z "$_filename" ]; then
    export MOCKFILE="$MOCKDIR"/"$_filename"

    mock._log "Created file: $MOCKFILE"
    touch "$MOCKFILE"

    if [ -n "$_content" ]; then
      mock._log "Adding content to $MOCKFILE"
      echo -e "$_content" > "$MOCKFILE"
    fi
  fi
}

mock.bin() {
  mock.dir bin $@
}

mock.lib() {
  mock.dir lib $@
}

mock.man() {
  mock.dir man $@
}

mock.util() {
  mock.dir util $@
}

mock.deinit() {
  unset __MOCKDIR__
}

mock.pushd() {
  pushd $__MOCKDIR__ > /dev/null
}

mock.popd() {
  popd > /dev/null
}

mock.is_initialized() {
  if [ -z ${__MOCKDIR__+x} ]; then
    return 1
  fi

  return 0
}

export -f mock._log \
          mock.init \
          mock.dir \
          mock.bin \
          mock.lib \
          mock.man \
          mock.util \
          mock.deinit \
          mock.pushd \
          mock.popd \
          mock.is_initialized

# test.mock
