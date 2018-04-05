#!/usr/bin/env bash

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

# builder.find
