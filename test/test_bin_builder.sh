#!/usr/bin/env bash

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../lib" && pwd )"/bin-builder.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/_utils/mock.sh

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

  pushd $__MOCKDIR__ > /dev/null
    if [ $_error -ne 0 ]; then
      assert_fails "bin-builder $_args"
    else
      assert "bin-builder $_args"
    fi
  popd > /dev/null
}

###
# Checks that an sh file under lib creates a symbolic link under bin
##
test_bin_builder_bin_gets_created() {
  mock.init
  mock.lib "foo.sh"

  call

  assert "test -d $__MOCKDIR__/bin"
  assert "test -L $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.sh'"

  mock.deinit
}

###
# Checks that a non sh file under lib does not created under bin
##
test_bin_builder_ignores_non_sh_by_default() {
  mock.init
  mock.lib "foo.sh"
  mock.lib "bar.py"

  call

  assert "test -d $__MOCKDIR__/bin"
  assert "test ! -L $__MOCKDIR__/bin/bar"

  mock.deinit
}

###
# Checks that the first parameter changes the bin directory
##
test_bin_builder_first_parameter_sets_bin() {
  mock.init
  mock.lib "foo.sh"

  call "_bin"

  assert "test -d $__MOCKDIR__/_bin"
  assert "test -L $__MOCKDIR__/_bin/foo"

  mock.deinit
}

###
# Checks that the second parameter changes the lib directory
##
test_bin_builder_second_parameter_sets_lib() {
  mock.init
  mock.dir "_lib" "foo.sh"

  call "bin" "_lib"

  assert "test -d $__MOCKDIR__/bin"
  assert "test -L $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../_lib/foo.sh'"

  mock.deinit
}

###
# Checks that the third parameter changes the sh extension
##
test_bin_builder_third_parameter_sets_ext() {
  mock.init
  mock.lib "foo.py"

  call "bin" "lib" ".py"

  assert "test -d $__MOCKDIR__/bin"
  assert "test -L $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.py'"

  mock.deinit
}

###
# Bins will be overwritten if already existing and force flag is set
##
test_bin_builder_force_set_to_true() {
  mock.init
  mock.lib "foo.sh"
  mock.bin "foo"

  call --force

  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.sh'"

  mock.deinit
}

###
# Bins do not need to be overwritten if the link is the desired link to set
##
test_bin_builder_force_is_not_set_but_link_already_exists() {
  mock.init
  mock.lib "foo.sh"
  mock.bin

  $( cd $MOCKDIR && ln -s ../lib/foo.sh )

  call

  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.sh'"

  mock.deinit
}

###
# Bins need to be overwritten if the link is not the desired link to set
##
test_bin_builder_force_is_not_set_but_different_link_already_exists() {
  mock.init
  mock.lib "foo.sh"
  mock.lib "bar.sh"
  mock.bin

  $( cd $MOCKDIR && ln -s ../lib/bar.sh foo )

  call --error

  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/bar.sh'"

  mock.deinit
}

###
# Bins will be overwritten if force is set
##
test_bin_builder_force_is_set_and_different_link_already_exists() {
  mock.init
  mock.lib "foo.sh"
  mock.lib "bar.sh"
  mock.bin

  $( cd $MOCKDIR && ln -s ../lib/bar.sh foo )

  call --force

  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.sh'"

  mock.deinit
}

# builder test
