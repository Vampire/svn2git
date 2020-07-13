#!/bin/bash

set -euo pipefail

# Ensure needed tools are present
svn --version >/dev/null
git --version >/dev/null
tar --version >/dev/null

# Determine script_dir
# Resolve links: $0 may be a link
prg="$0"
# Need this for relative symlinks.
while [ -h "$prg" ]; do
    ls=$(ls -ld "$prg")
    link=$(expr "$ls" : '.*-> \(.*\)$')
    if expr "$link" : '/.*' >/dev/null; then
        prg="$link"
    else
        prg=$(dirname "$prg")"/$link"
    fi
done
cd "$(dirname "$prg")/" >/dev/null
script_dir="$(pwd -P)"

if [ "${1-}" == "--no-make" ]; then
    shift
else
    qmake
    make
fi

args=()
test_given=""
for arg in "$@"; do
    if [[ "$(echo "$arg/"*.bats)" != *\** ]]; then
        args+=("$arg")
        test_given="test_given"
    elif [ -f "test/$arg.bats" ]; then
        args+=("test/$arg.bats")
        test_given="test_given"
    else
        args+=("$arg")
    fi
done
[ "$test_given" ] || args+=("test")

mkdir -p "$script_dir/build/tmp"
TMPDIR="$script_dir/build/tmp" test/libs/bats-core/bin/bats "${args[@]}"
