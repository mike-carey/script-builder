#!/usr/bin/env bash

call() {
  local _fn
  local _args
  local _assert
  local _error=0
  local _message=""

  while : ; do
    case "$1" in
      +assert )
        _assert="$2"
        shift
        shift
        ;;
      +error )
        _error=1
        shift
        ;;
      +function )
        _fn="$2"
        shift
        shift
        ;;
      +message )
        _message="$2"
        shift
        shift
        ;;
      ++ )
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
      assert_fails "$_args" "$_message"
    elif [ ! -z "$_fn" ]; then
      $_fn $_args
    elif [ ! -z "$_assert" ]; then
      _assert_expression \
        "$_args" \
        "$_assert" \
        "$_message"
    else
      assert "$_args" "$_message"
    fi

  if [ ! -z ${__MOCKDIR__+x} ]; then
    popd > /dev/null
  fi
}

export -f call
