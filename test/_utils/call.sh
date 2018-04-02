#!/usr/bin/env bash

call() {
  local _args
  local _error=0

  while : ; do
    case "$1" in
      -e | --error )
        _error=1
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

  _args="${@}"

  if [ ! -z ${__MOCKDIR__+x} ]; then
    pushd $__MOCKDIR__ > /dev/null
  fi

    if [ $_error -ne 0 ]; then
      assert_fails "$_args"
    else
      assert "$_args"
    fi

  if [ ! -z ${__MOCKDIR__+x} ]; then
    popd > /dev/null
  fi
}

export -f call
