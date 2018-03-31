#!/usr/bin/env bash

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../lib" && pwd )"/bin-builder.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/_utils/mock.sh

call() {
  local _args="${@}"
  local _output=/dev/null

  if [ ! -z ${TEST_VERBOSE+x} ]; then
    _output=/dev/stdout
  fi

  pushd $__MOCKDIR__ > /dev/null
    bin-builder $@ > "$_output"
  popd > /dev/null
}

###
# Checks that an sh file under lib creates a symbolic link under bin
##
test_bin_builder_bin_gets_created() {
  local bin

  mock.init
  mock.lib "foo.sh"

  call

  assert "test -d $__MOCKDIR__/bin"
  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.sh'"

  mock.deinit
}

###
# Checks that a non sh file under lib does not created under bin
##
test_bin_builder_ignores_non_sh_by_default() {
  local bin

  mock.init
  mock.lib "foo.sh"
  mock.lib "bar.py"

  call

  assert "test -d $__MOCKDIR__/bin"
  assert "test ! -h $__MOCKDIR__/bin/bar"

  mock.deinit
}

###
# Checks that the first parameter changes the bin directory
##
test_bin_builder_first_parameter_sets_bin() {
  local bin

  mock.init
  mock.lib "foo.sh"

  call "_bin"

  assert "test -d $__MOCKDIR__/_bin"
  assert "test -h $__MOCKDIR__/_bin/foo"

  mock.deinit
}

###
# Checks that the second parameter changes the lib directory
##
test_bin_builder_second_parameter_sets_lib() {
  local bin

  mock.init
  mock.dir "_lib" "foo.sh"

  call "bin" "_lib"

  assert "test -d $__MOCKDIR__/bin"
  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../_lib/foo.sh'"

  mock.deinit
}

###
# Checks that the third parameter changes the sh extension
##
test_bin_builder_third_parameter_sets_ext() {
  local bin

  mock.init
  mock.lib "foo.py"

  call "bin" "lib" ".py"

  assert "test -d $__MOCKDIR__/bin"
  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.py'"

  mock.deinit
}


###
# Bins get overriden if already existing
##
test_bin_builder_third_parameter_sets_ext() {
  local bin

  mock.init
  mock.lib "foo.py"

  call "bin" "lib" ".py"

  assert "test -d $__MOCKDIR__/bin"
  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.py'"

  mock.deinit
}

# builder test
