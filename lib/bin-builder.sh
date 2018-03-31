#!/usr/bin/env bash

###
# Parameters:
#   1 {directory=bin} The directory to place links into
#   2 {directory=lib} The directory to pull scripts from
#   3 {string=.sh} The extension to assume files will conform to
##
bin-builder() {
  local FORCE=1
  local BIN
  local LIB
  local EXT

  while : ; do
    case "$1" in
      --extension )
        EXT="$2"
        shift
        shift
        ;;
      -f | --force )
        FORCE=0
        shift
        ;;
      -- )
        shift
        break
        ;;
      * )
        break
        ;;
    esac
  done

  BIN=${1:-bin}
  LIB=${2:-lib}
  EXT=${3:-.sh}

  mkdir -p "$BIN"
  for i in $( cd "$LIB" && ls *${EXT} ); do
    local _bin="$BIN/${i/${EXT}/}"
    local _lib="../$LIB/$i"
    echo "Linking '$_bin' -> '$_lib'"
    if [ $FORCE -ne 0 -a ! [ -h "$_bin" -o "$( readlink -- "$_bin" )" != "$_lib" ] ]; then
      echo "Cowardly refusing to overwrite '$_bin'" >&2
      return 3
    fi

    $( cd "$BIN" && ln -fs "$_lib" "${_bin/${BIN}/}" )
  done
}

if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  export -f bin-builder
else
  bin-builder "${@}"
  exit $?
fi

# bins
