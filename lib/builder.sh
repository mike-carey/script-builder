#!/usr/bin/env bash

###
# Finds the realpath of a file or directory
##
_realpath() {
  echo "$( cd "$1" && pwd )"
}

###
# Checks that concat is loaded or in the path
##
_concat() {
  local _path="$1"/concat

  type -f concat >/dev/null 2>&1 || hash concat >/dev/null 2>&1 || {
    if [ ! -e "$_path" ]; then
      _path="$_path.sh"
    fi

    echo "Cannot find concat function. Attempting to source '$_path'"
    source "$_path"
  }
}

_concat "$( _realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

###
# Builds full shell scripts using utils
#
# Parameters:
#   @ {files...} The files to build
##

###
# Searches a directory for files with the name matching name
#
# Parameters:
#   1 {directory} The directory to search
#   2 {string} The name to search for using find
##
builder.find() {
  local _dir="$1"
  local _name="$2"

  if [ -z "$_dir" -o -z "$_name" ]; then
    echo "Usage builder.find DIR NAME" >&2
    return 5
  fi

  declare -a _value=()
  if [ -d "$_dir" ]; then
    for d in $( find "$_dir" -name "$_name" ); do
      _value+=("$d")
    done
  # else
  #   echo "'$_dir' is not a directory"
  fi

  echo "${_value[@]}"

  return 0
}

# util.build
