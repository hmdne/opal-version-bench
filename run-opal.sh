#!/bin/bash
pushd "$1" >/dev/null 2>&1
shift
bundle install >/dev/null 2>&1
bin/opal "$@"
popd >/dev/null 2>&1
