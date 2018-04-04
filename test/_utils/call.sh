#!/usr/bin/env bash

call() {
  local _fn
  local _args
  local _assert
  local _error=0
  local _message=""
  local _expression

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
      +expression )
        _expression="$2"
        shift
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

  if mock.is_initialized ; then
    mock.pushd
  fi

    if [ $_error -ne 0 ]; then
      assert_fails "$_args" "$_message"
    elif [ ! -z "$_fn" ]; then
      $_fn $_args
    elif [ ! -z "$_assert" ]; then
      "$_assert" \
        "$_args" \
        "$_expression" \
        "$_message"
    elif [ ! -z "$_expression" ]; then
      _assert_expression \
        "$_args" \
        "$_expression" \
        "$_message"
    else
      assert "$_args" "$_message"
    fi

  if mock.is_initialized ; then
    mock.popd
  fi
}

export -f call
