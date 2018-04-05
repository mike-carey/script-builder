#!/usr/bin/env bash

fake hash '{ return 0; }'

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"/src/builder/builder.find.sh

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/call.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/mock.sh

setup_suite() {
  declare -a var=()
}

###
# All parameters are required for builder.find
##
test_builder.find_require_all_parameters() {
  call +error builder.find
  call +error builder.find dir
  call builder.find dir name
}

###
# No directory comes as empty array
##
test_builder.find_no_directory() {
  mock.init

  call \
    +expression "[ \"\$(cat \$stdout | head -n 1)\" = \"\" ]" \
    builder.find 'lib' '*.sh'

  mock.deinit
}

###
# Empty directory comes as empty array
##
test_builder.find_empty_directory() {
  mock.init

  mock.lib

  call \
    +expression "[ \"\$(cat \$stdout | head -n 1)\" = \"\" ]" \
    builder.find 'lib' '*.sh'

  mock.deinit
}

###
# One file in directory comes as an array of one
##
test_builder.find_one_file() {
  mock.init

  mock.lib 'foo.sh'

  call \
    +expression "[ \"\$(cat \$stdout | head -n 1)\" = \"lib/foo.sh\" ]" \
    builder.find 'lib' '*.sh'

  mock.deinit
}

###
# Two files in directory comes as an array of two
##
test_builder.find_multiple_files() {
  mock.init

  mock.lib 'foo.sh'
  mock.lib 'bar.sh'

  call \
    +expression "[ \"\$(cat \$stdout | head -n 1)\" = \"lib/bar.sh lib/foo.sh\" ]" \
    builder.find 'lib' '*.sh'

  mock.deinit
}
