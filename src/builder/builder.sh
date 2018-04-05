#!/usr/bin/env bash

###
#
# Environment:
#   BUILDER_LIB {directory=lib} The directory where scripts are kept.
#   BUILDER_UTIL {directory=util} The directory where utility scripts to be
#                                   prepended are kept.
#   BUILDER_DIST {directory=dist} The directory to place output to.
#   BUILDER_EXT {string=.sh} The extension for files to search for.
#
# Options:
#   --dist {directory} The directory to place output to.  See
#                       Environment#BUILDER_DIST
#   --util {directory} The directory where utility scripts to be prepended are
#                       kept.  See Environment#BUILDER_UTIL
#   --lib {diectory} The directory where scripts are kept.  See
#                     Environment#BUILDER_LIB
#   --ext {string} The extension for files to search for.  See
#                     Environment#BUILDER_EXT
#   --single-file {boolean} Tells the builder to combine everything into one
#                             file.
#   -- {boolean} Indicates the end of arguments.
##
builder() {
  local _dist="${BUILDER_DIST:-dist}"
  local _util="${BUILDER_UTIL:-util}"
  local _lib="${BUILDER_LIB:-lib}"
  local _ext="${BUILDER_EXT:-.sh}"
  local _single_file

  while : ; do
    case "$1" in
      --dist )
        _dist="$2"
        shift
        shift
        ;;
      --util )
        _util="$2"
        shift
        shift
        ;;
      --lib )
        _lib="$2"
        shift
        shift
        ;;
      --ext )
        _ext="$2"
        shift
        shift
        ;;
      --single-file )
        _single_file="$2"
        shift
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

  if [[ "$@" = \- && -z "$_single_file" ]]; then
    # We will generate a random name
    # echo "Creating a random name for single file" >&2
    _single_file="$_dist/$( cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 )$_ext"

    # Take the '-' off the params
    shift
  fi

  local -a _files=($@)
  local -a _utils=($( builder.find "$_util" "*$_ext" ))

  if [ ${#_files[@]} -eq 0 ]; then
    if [ ! -d $_lib ]; then
      {
        echo "When no files are provided, the lib directory is required"
        echo "Please set the lib directory via \`--lib\` option or the \`BUILDER_LIB\` variable"
      } >&2
      return 4
    # else
    #   echo "'$_lib' is a directory"
    fi

    _files=($( builder.find "$_lib" "*$_ext" ))
  # else
  #   echo "Files were provided: '${_files[@]}'" >&2
  fi

  mkdir -p "$_dist"

  if [ -n "$_single_file" ]; then
    # echo "Single file: '$_single_file'" >&2

    concat "$_single_file" ${_utils[@]} ${_files[@]}
    chmod +x "$_single_file"

    export BUILDER_DIST_FILE="$_single_file"

    echo "$BUILDER_DIST_FILE"
  else
    # echo "Not single file" >&2

    mkdir -p "$_dist"

    declare -a BUILDER_DIST_FILES=()
    for _file in ${_files[@]}; do
      concat "$_dist"/"$_file" ${_utils[@]} "$_file"
      chmod +x "$_dist"/"$_file"

      BUILDER_DIST_FILES+=("$_file")
    done

    export BUILDER_DIST_FILES

    echo "${BUILDER_DIST_FILES[@]}"
  fi

  return 0
}

# builder
