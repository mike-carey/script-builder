#!/usr/bin/env bash

###
# Parameters:
#   1 {directory=bin} The directory to place links into
#   2 {directory=lib} The directory to pull scripts from
#   3 {string=.sh} The extenstion to assume files will conform to
##
bin-builder() {
  BIN=${1:-bin}
  LIB=${2:-lib}
  EXT=${3:-.sh}

  mkdir -p "$BIN"
  for i in $( cd "$LIB" && ls *${EXT} ); do
    echo "Linking '$BIN/${i/${EXT}/}' -> '../$LIB/$i'"
    $( cd "$BIN" && ln -fs ../"$LIB"/"$i" "${i/${EXT}/}" )
  done
}

if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  export -f bin-builder
else
  bin-builder "${@}"
  exit $?
fi

# bins
