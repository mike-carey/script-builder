#!/usr/bin/env bash

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"/src/builder/builder.sh

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/call.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/mock.sh

setup() {
  if [ -n ${BUILDER_DIST_FILE+x} ]; then
    unset BUILDER_DIST_FILE
  fi
  if [ -n ${BUILDER_DIST_FILES+x} ]; then
    unset BUILDER_DIST_FILES
  fi
  builder.find() { echo ''; }
  concat() {
    if [ -z "${@:2}" ]; then
      touch $1
    else
      cat ${@:2} > $1
    fi
  }
}

###
# Checks that the BUILDER_DIST_FILE variable is exported
##
test_builder_BUILDER_DIST_FILE_variable_is_exported() {
  mock.init

  mock.lib

  call builder "-"

  assert "test -z \"${BUILDER_DIST_FILE+x}\""

  mock.deinit
}

###
# Checks that the BUILDER_DIST_FILES variable is exported
##
test_builder_BUILDER_DIST_FILES_variable_is_exported() {
  mock.init

  call builder "build.sh"

  assert "test -z \"${BUILDER_DIST_FILES+x}\""

  mock.deinit
}

###
# No parameters passed in and no lib directory should error

##
test_builder_no_params_and_no_lib() {
  mock.init

  call +error builder

  mock.deinit
}

test_builder_-() {
  local _content='foo'

  mock.init

  mock.lib "foo.sh" "$_content"

  builder.find() {
    if [ "$1" = "lib" ]; then
      echo 'lib/foo.sh'
    else
      echo ''
    fi
  }

  mock.pushd
    builder -

    assert "test -n '$BUILDER_DIST_FILE'" "BUILDER_DIST_FILE is not set"
    assert "test -f $BUILDER_DIST_FILE" "'$BUILDER_DIST_FILE' is not a file"
    assert "test '$(cat $BUILDER_DIST_FILE)' = 'foo'" "Contents of '$BUILDER_DIST_FILE' do not match"
  mock.popd

  mock.deinit
}

# ###
# #
# ##
# test_builder_no_params_and_lib_exists_but_empty() {
#   mock.init
#
#   call +error builder
#
#   mock.deinit
# }
