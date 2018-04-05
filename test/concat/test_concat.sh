#!/usr/bin/env bash

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"/src/concat/concat.sh

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/call.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/mock.sh

###
# Checks that the output path is provided
##
test_concat_required_output_file() {
  mock.init

  call +error concat

  mock.deinit
}

###
# Checks that the input path is provided
##
test_concat_required_input_files() {
  mock.init

  call +error concat "build.sh"

  mock.deinit
}

###
# Checks that the blob is not empty
##
test_concat_blob_is_empty() {
  mock.init

  mock.lib "foo.sh"

  call +error concat "build.sh" "lib/foo.sh"

  mock.deinit
}

###
# Checks that the content is in the file
##
test_concat_output_is_created_with_content() {
  local _content="#!/usr/bin/env bash\n\nfunction foo() {\necho \"foo\"\n}"

  mock.init

  mock.dir lib "foo.sh" "$_content"

  call concat "build.sh" "lib/foo.sh"

  assert "test -f $__MOCKDIR__/build.sh"

  mock.dir "tmp" "expected.sh"
  local _expected=$MOCKFILE
  mock.dir "tmp" "actual.sh"
  local _actual=$MOCKFILE

  $( source $__MOCKDIR__/lib/foo.sh && declare -f foo > $_expected )
  $( source $__MOCKDIR__/build.sh && declare -f foo > $_actual )

  assert "diff -qw $_expected $_actual"

  mock.deinit
}

###
# Checks that the content is in the file
##
test_concat_output_is_created_with_all_content() {
  local _foo_content="#!/usr/bin/env bash\n\nfunction foo() {\necho \"foo\"\n}"
  local _bar_content="#!/usr/bin/env bash\n\nfunction bar() {\necho \"bar\"\n}"

  mock.init

  mock.dir lib "foo.sh" "$_foo_content"
  mock.dir lib "bar.sh" "$_bar_content"

  call concat "build.sh" "lib/foo.sh" "lib/bar.sh"

  assert "test -f $__MOCKDIR__/build.sh"

  # mock.dir "tmp" "expected.sh"
  local _expected="$__MOCKDIR__/build.sh"
  mock.dir "tmp" "actual.sh"
  local _actual=$MOCKFILE

  echo -e "#!/usr/bin/env bash\nfunction foo () \n{\necho \"foo\"\n};\nfunction bar () \n{\necho \"bar\"\n}" > $_actual

  assert "diff -wEbB --strip-trailing-cr $_expected $_actual"

  mock.deinit
}
