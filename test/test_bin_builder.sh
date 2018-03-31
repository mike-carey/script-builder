#!/usr/bin/env bash

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../lib" && pwd )"/bin-builder.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/_utils/mock.sh

test_bin_builder_bin_gets_created() {
  local bin

  mock.init
  mock.lib "test.sh"

  pushd $__MOCKDIR__ > /dev/null
    bin-builder
  popd > /dev/null

  assert "test -d $__MOCKDIR__/bin"
  assert "test -h $__MOCKDIR__/bin/test"

  mock.deinit
}

# builder test
