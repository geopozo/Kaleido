#!/bin/bash
set -e
set -u

# Please do your flags first so that utilities uses $NO_VERBOSE, otherwise failure!
usage=(
  "init_tools will run some some commands that google recommends or requires before other build steps."
  "It can be version and platform dependent."
  ""
  "Usage (DO NOT USE --long-flags=something, just --long-flag something):"
  "You can always try -v or --verbose"
  ""
  "Display this help:"
  "init_tools [-h|--h]"
  ""
  "Dry run: just show me the scripts that would be run, don't run them."
  "init_tools [-d|--dry-run]"
  ""
  ""
)
## PROCESS FLAGS

FLAGS=("-d" "--dry-run")
ARGFLAGS=()

SCRIPT_DIR=$( cd -- "$( dirname -- $(readlink -f -- "${BASH_SOURCE[0]}") )" &> /dev/null && pwd )
. "$SCRIPT_DIR/include/utilities.sh"

SHOW="$(flags_resolve false "-d" "--dry-run")"

$NO_VERBOSE || echo "Running 02-init_tools.sh"

util_get_version
util_export_version

# This may change with depot tools vesion, and it still needs to be worked out per platform
if [[ "$PLATFORM" == "WINDOWS" ]]; then
  $NO_VERBOSE || echo "TODO" # TODO (look at your comment in fetch_chromium)
elif [[ "$PLATFORM" == "LINUX" ]]; then
  mkdir -p "$MAIN_DIR/toolchain/tmp"
  # I don't love curling this out of something we'll download later but its how they do it and we haven't cloned the repo yet
  # https://issues.chromium.org/issues/40243622

  if [[ "$CHROMIUM_VERSION_TAG" == "88.0.4324.150" ]]; then
    util_error "Script exiting as 88.0.4324.150's build script doesn't seem to function, look at 02-init_tools.sh if important"
    #### THIS IS WHAT IT WAS:

    curl -s https://chromium.googlesource.com/chromium/src/+/$CHROMIUM_VERSION_TAG/build/install-build-deps.sh?format=TEXT \
    | base64 -d > $MAIN_DIR/toolchain/tmp/install-build-deps.sh
    if $SHOW; then
      echo -e "\n\nSee file in $MAIN_DIR/toolchain/tmp/install-build-deps.sh"
      exit 0
    fi
    chmod +x "$MAIN_DIR/toolchain/tmp/install-build-deps.sh"
    "$MAIN_DIR/toolchain/tmp/install-build-deps.sh" --no-syms --no-arm --no-chromeos-fonts --no-nacl --no-prompt
  elif [[ "$CHROMIUM_VERSION_TAG" == "126.0.6478.126" ]]; then
    curl -s https://chromium.googlesource.com/chromium/src/+/$CHROMIUM_VERSION_TAG/build/install-build-deps.sh?format=TEXT \
    | base64 -d > $MAIN_DIR/toolchain/tmp/install-build-deps.sh
    curl -s https://chromium.googlesource.com/chromium/src/+/$CHROMIUM_VERSION_TAG/build/install-build-deps.sh?format=TEXT \
    | base64 -d > $MAIN_DIR/toolchain/tmp/install-build-deps.py
    if $SHOW; then
      echo -e "\n\nSee file in $MAIN_DIR/toolchain/tmp/install-build-deps.sh"
      echo -e "\n\nSee file in $MAIN_DIR/toolchain/tmp/install-build-deps.py"
      exit 0
    fi
    chmod +x "$MAIN_DIR/toolchain/tmp/install-build-deps.sh"
    "$MAIN_DIR/toolchain/tmp/install-build-deps.sh" --no-syms --no-arm --no-chromeos-fonts --no-nacl --no-prompt

  else
    util-error "Unknown CHROMUM_VERSION_TAG, please create a branch for it in 02-init_tools.sh"
  fi
  # runhooks? i don't think we need to TODO but mentioned
  $NO_VERBOSE || echo "Downloaded and installed build-deps."
elif [[ "$PLATFORM" == "OSX" ]]; then
  $NO_VERBOSE || echo "Did nothing for OSX, we will have to do something, probably the same as linux." # TODO
fi