#!/usr/bin/env bash

declare -r TEST_BINS_BASE_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

test_bin-builder() {
  source "$TEST_BINS_BASE_DIRECTORY"/bin/bin-builder

  assert "declare -f bin-builder"
}

test_builder() {
  source "$TEST_BINS_BASE_DIRECTORY"/bin/builder

  assert "declare -f builder"
}

test_concat() {
  source "$TEST_BINS_BASE_DIRECTORY"/bin/concat

  assert "declare -f concat"
}
