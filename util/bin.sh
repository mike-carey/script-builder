#!/bin/bash

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/src/bin-builder/bin-builder.sh

util.bin() {
  bin-builder
}

if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  echo "Cannot run this via source.  Please run build as a file" >&2
  exit 255
else
  util.bin "${@}"
  exit $?
fi

# util.bin
