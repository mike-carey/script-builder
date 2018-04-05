#!/usr/bin/env bash

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"/src/builder/builder.sh

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/call.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"/_utils/mock.sh

declare -r __UNSET__=( BUILDER_DIST BUILDER_UTIL BUILDER_LIB BUILDER_EXT BUILDER_DIST_FILE BUILDER_DIST_FILES )

setup() {
  for i in ${__UNSET__[@]}; do
    unset $i >/dev/null 2>&1
  done

  builder.find() {
    if [ ! -d "$1" ]; then
      echo ''
    else
      echo $( find "$1" -name '*.sh' )
    fi
  }
  concat() {
    mkdir -p "$( dirname "$1" )"
    if [[ -z "${@:2}" ]]; then
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
  mock.tmp "output"
  local _output=$MOCKFILE

  mock.pushd
    builder - > $_output

    assert "test -n '${BUILDER_DIST_FILE+x}'" 'BUILDER_DIST_FILE is not set'
    assert "test '${BUILDER_DIST_FILE}' = '$(cat $_output)'" 'BUILDER_DIST_FILE does not match the printed content'
  mock.popd

  mock.deinit
}

###
# Checks that the BUILDER_DIST_FILES variable is exported
##
test_builder_BUILDER_DIST_FILES_variable_is_exported() {
  mock.init

  mock.lib "build.sh"
  mock.tmp "output"
  local _output=$MOCKFILE

  mock.pushd
    builder "lib/build.sh" > $_output

    assert "test -n '${BUILDER_DIST_FILES+x}'" 'BUILDER_DIST_FILES is not set'
    assert "test '${BUILDER_DIST_FILES}' = '$(cat $_output)'" 'BUILDER_DIST_FILES does not match the printed content'
  mock.popd

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

###
# Providing a single - as parameters should result in BUILDER_DIST_FILE being set and the contents should be a concat of the lib directory.
##
test_builder_-() {
  local _content='foo'

  mock.init

  mock.lib "foo.sh" "$_content"

  mock.pushd
    builder - > /dev/null

    assert "test -n '${BUILDER_DIST_FILE+x}'" "BUILDER_DIST_FILE is not set"
    assert "test -f $BUILDER_DIST_FILE" "'$BUILDER_DIST_FILE' is not a file"
    assert "test '$(cat $BUILDER_DIST_FILE)' = 'foo'" "Contents of '$BUILDER_DIST_FILE' do not match"
  mock.popd

  mock.deinit
}

###
# Providing --single-file and - should result in BUILDER_DIST_FILE being set to the file provided to single-file and the contents should be a concat of the lib directory.
##
test_builder_single_file_provided_with_-() {
  local _content='foo'
  local _file='dist/build.sh'

  mock.init

  mock.lib "foo.sh" "$_content"

  mock.pushd
    builder --single-file "$_file" - > /dev/null

    assert "test -n '${BUILDER_DIST_FILE+x}'" "BUILDER_DIST_FILE is not set"
    assert "test '$BUILDER_DIST_FILE' = '$_file'"
    assert "test -f $BUILDER_DIST_FILE" "'$BUILDER_DIST_FILE' is not a file"
    assert "test '$(cat $BUILDER_DIST_FILE)' = 'foo'" "Contents of '$BUILDER_DIST_FILE' do not match"
  mock.popd

  mock.deinit
}

###
# No parameters are passed in, lib exists, but is empty results in an empty list of BUILDER_DIST_FILES
##
test_builder_no_params_and_lib_exists_but_empty() {
  mock.init

  mock.lib

  mock.pushd
    builder > /dev/null

    assert "test -n '${BUILDER_DIST_FILES+x}'" 'BUILDER_DIST_FILES is not set'
    assert "test '${BUILDER_DIST_FILES}' = ''" 'BUILDER_DIST_FILES is not empty'
  mock.popd

  mock.deinit
}

###
# No parameters are passed in, lib exists, but has one result in a list of one BUILDER_DIST_FILES
##
test_builder_no_params_and_lib_exists_with_one_file() {
  mock.init

  mock.lib "foo.sh" "foo"

  mock.pushd
    builder > /dev/null

    assert "test -n '${BUILDER_DIST_FILES+x}'" 'BUILDER_DIST_FILES is not set'
    assert "test '${BUILDER_DIST_FILES}' = 'dist/lib/foo.sh'" 'BUILDER_DIST_FILES does not have the one entry'
  mock.popd

  mock.deinit
}

###
# No parameters are passed in, lib exists, but has one result in a list of one BUILDER_DIST_FILES
##
test_builder_no_params_and_lib_exists_with_two_files() {
  mock.init

  mock.lib "foo.sh" "foo"
  mock.lib "bar.sh" "bar"

  mock.pushd
    builder > /dev/null

    assert "test -n '${BUILDER_DIST_FILES+x}'" 'BUILDER_DIST_FILES is not set'
    assert "test '${BUILDER_DIST_FILES}' = 'dist/lib/bar.sh dist/lib/foo.sh'" 'BUILDER_DIST_FILES does not have the two entries'
  mock.popd

  mock.deinit
}

###
# One parameter is passed in and the single-file flag was not set
##
test_builder_one_param_without_single_file_flag() {
  mock.init

  mock.bin "foo.sh" "foo"

  mock.pushd
    builder "bin/foo.sh" > /dev/null

    assert "test -n '${BUILDER_DIST_FILES+x}'" 'BUILDER_DIST_FILES is not set'
    assert "test '${BUILDER_DIST_FILES}' = 'dist/bin/foo.sh'" 'BUILDER_DIST_FILES does not have the two entries'
  mock.popd

  mock.deinit
}

###
# Parameters are passed in and the single-file flag was not set
##
test_builder_one_param_without_single_file_flag() {
  mock.init

  mock.bin "foo.sh" "foo"
  mock.bin "bar.sh" "bar"

  mock.pushd
    builder "bin/bar.sh" "bin/foo.sh" > /dev/null

    assert "test -n '${BUILDER_DIST_FILES+x}'" 'BUILDER_DIST_FILES is not set'
    assert "test '${BUILDER_DIST_FILES}' = 'dist/bin/bar.sh dist/bin/foo.sh'" 'BUILDER_DIST_FILES does not have the two entries'
  mock.popd

  mock.deinit
}

###
# Parameters are passed in and the single-file flag was set
##
test_builder_params_with_single_file_flag() {
  mock.init

  mock.bin "foo.sh" "foo"
  mock.bin "bar.sh" "bar"

  mock.tmp "expected" "foo\nbar"
  local _expected=$MOCKFILE

  mock.pushd
    builder --single-file "dist/baz.sh" "bin/foo.sh" "bin/bar.sh" > /dev/null

    assert "test -n '${BUILDER_DIST_FILE+x}'" 'BUILDER_DIST_FILE is not set'
    assert "test '${BUILDER_DIST_FILE}' = 'dist/baz.sh'" 'BUILDER_DIST_FILE does not have the correct entry'
    assert "diff -w '$BUILDER_DIST_FILE' '$_expected'" "File contents do not match: '$BUILDER_DIST_FILE' <> '$_expected'"
  mock.popd

  mock.deinit
}

###
# Parameters are passed in and the single-file flag was not set
##
test_builder_params_with_single_file_flag_as_-() {
  mock.init

  mock.bin "foo.sh" "foo"
  mock.bin "bar.sh" "bar"

  mock.tmp "expected" "foo\nbar"
  local _expected=$MOCKFILE

  mock.pushd
    builder --single-file - "bin/foo.sh" "bin/bar.sh" > /dev/null

    assert "test -n '${BUILDER_DIST_FILE+x}'" 'BUILDER_DIST_FILE is not set'
    assert "diff -w '$BUILDER_DIST_FILE' '$_expected'" "File contents do not match: '$BUILDER_DIST_FILE' <> '$_expected'"
  mock.popd

  mock.deinit
}
