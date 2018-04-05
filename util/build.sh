#!/bin/bash

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/src/concat/concat.sh

declare -r __BASEDIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

IN=src
OUT=lib

APPEND="""
if [[ \${BASH_SOURCE[0]} != \$0 ]]; then
  export -f {{FUNCTION}}
else
  {{FUNCTION}} \"\${@}\"
  exit \$?
fi
"""

cd "$__BASEDIR__"
mkdir -p $OUT

###
#
##
util.build() {
  local _dir
  local _args=

  for _dir in "$IN"/* ; do
    if [ -d $_dir ]; then
      local _name="$( basename "$_dir" )"

      _args="$OUT/$_name.sh $( find "$_dir" -name '*.sh' )"

      local _tmp=$(mktemp)
      echo -e "${APPEND/\{\{FUNCTION\}\}/$_name}" > "$_tmp"
      _args+=" $_tmp"

      concat $_args
    fi
  done
}

if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  echo "Cannot run this via source.  Please run build as a file" >&2
  exit 255
else
  util.build "${@}"
  exit $?
fi

# util.build
