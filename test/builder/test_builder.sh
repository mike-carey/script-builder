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

  export -f builder.find

  call +error builder

  mock.deinit
}
