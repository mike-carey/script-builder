#!/usr/bin/env bash

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"/src/bin-builder/bin-builder.sh

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/call.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/mock.sh

###
# Checks that an sh file under lib creates a symbolic link under bin
##
test_bin-builder_bin_gets_created() {
  mock.init

  mock.lib "foo.sh"

  call bin-builder

  assert "test -d $__MOCKDIR__/bin"
  assert "test -L $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.sh'"

  mock.deinit
}

###
# Checks that a non sh file under lib does not created under bin
##
test_bin-builder_ignores_non_sh_by_default() {
  mock.init

  mock.lib "foo.sh"
  mock.lib "bar.py"

  call bin-builder

  assert "test -d $__MOCKDIR__/bin"
  assert "test ! -L $__MOCKDIR__/bin/bar"

  mock.deinit
}

###
# Checks that the first parameter changes the bin directory
##
test_bin-builder_first_parameter_sets_bin() {
  mock.init

  mock.lib "foo.sh"

  call bin-builder "_bin"

  assert "test -d $__MOCKDIR__/_bin"
  assert "test -L $__MOCKDIR__/_bin/foo"

  mock.deinit
}

###
# Checks that the second parameter changes the lib directory
##
test_bin-builder_second_parameter_sets_lib() {
  mock.init

  mock.dir "_lib" "foo.sh"

  call bin-builder "bin" "_lib"

  assert "test -d $__MOCKDIR__/bin"
  assert "test -L $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../_lib/foo.sh'"

  mock.deinit
}

###
# Checks that the third parameter changes the sh extension
##
test_bin-builder_third_parameter_sets_ext() {
  mock.init

  mock.lib "foo.py"

  call bin-builder "bin" "lib" ".py"

  assert "test -d $__MOCKDIR__/bin"
  assert "test -L $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.py'"

  mock.deinit
}

###
# Bins will be overwritten if already existing and force flag is set
##
test_bin-builder_force_set_to_true() {
  mock.init

  mock.lib "foo.sh"
  mock.bin "foo"

  call bin-builder --force

  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.sh'"

  mock.deinit
}

###
# Bins do not need to be overwritten if the link is the desired link to set
##
test_bin-builder_force_is_not_set_but_link_already_exists() {
  mock.init

  mock.lib "foo.sh"
  mock.bin

  $( cd $MOCKDIR && ln -s ../lib/foo.sh )

  call bin-builder

  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.sh'"

  mock.deinit
}

###
# Bins need to be overwritten if the link is not the desired link to set
##
test_bin-builder_force_is_not_set_but_different_link_already_exists() {
  mock.init

  mock.lib "foo.sh"
  mock.lib "bar.sh"
  mock.bin

  $( cd $MOCKDIR && ln -s ../lib/bar.sh foo )

  call +error bin-builder

  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/bar.sh'"

  mock.deinit
}

###
# Bins will be overwritten if force is set
##
test_bin-builder_force_is_set_and_different_link_already_exists() {
  mock.init

  mock.lib "foo.sh"
  mock.lib "bar.sh"
  mock.bin

  $( cd $MOCKDIR && ln -s ../lib/bar.sh foo )

  call bin-builder --force

  assert "test -h $__MOCKDIR__/bin/foo"
  assert "test '$( readlink -- $__MOCKDIR__/bin/foo )' = '../lib/foo.sh'"

  mock.deinit
}

# builder test
