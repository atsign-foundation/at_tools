#!/bin/bash

script_dir="$(dirname -- "$(readlink -f -- "$0")")"
cd "$script_dir/.." || exit 1 # cd to root of repo

melos bootstrap --scope=at_cli --scope=at_cram --scope=at_pkam --scope=at_repl

mkdir -p build-tools

dart compile exe packages/at_cli/bin/main.dart -o build-tools/at_cli
dart compile exe packages/at_cram/bin/at_cram.dart -o build-tools/at_cram
dart compile exe packages/at_pkam/bin/main.dart -o build-tools/at_pkam
dart compile exe packages/at_repl/bin/at_repl.dart -o build-tools/at_repl
