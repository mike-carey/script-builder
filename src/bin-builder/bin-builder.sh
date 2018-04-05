#!/usr/bin/env bash

###
# Parameters:
#   1 {directory=bin} The directory to place links into
#   2 {directory=lib} The directory to pull scripts from
#   3 {string=.sh} The extension to assume files will conform to
##
bin-builder() {
  local _force=1
  local _bin
  local _lib
  local _ext

  while : ; do
    case "$1" in
      --extension )
        _ext="$2"
        shift
        shift
        ;;
      -f | --force )
        _force=0
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

  _bin=${1:-bin}
  _lib=${2:-lib}
  _ext=${3:-.sh}

  mkdir -p "$_bin"
  for i in $( cd "$_lib" && ls *${_ext} ); do
    local _link="$_bin/${i/${_ext}/}"
    local _file="../$_lib/$i"

    # It exists
    if [ -e "$_link" ]; then
      # It is not the symlink desired
      if [ ! -h "$_link" -o "$( readlink -- "$_link" )" != "$_file" ]; then
        # Cannot force it
        if [ $_force -ne 0 ]; then
          echo "Cowardly refusing to overwrite '$_link'" >&2
          return 2
        # else
        #   echo "Forcing"
        fi
      # else
      #   echo "Link is correct"
      fi
    # else
    #   echo "Bin ($_link) is not real"
    fi

    echo "Linking '$_link' -> '$_file'"
    $( cd "$_bin" && ln -fs "$_file" "${_link/${_bin}\//}" )
  done
}

# bin-builder
