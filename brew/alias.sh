#!/bin/bash

_DIR_=$(cd "$(dirname "$0")" && pwd)

brew() {
  if [[ $@ == "update --cask" ]]; then
    source "${_DIR_}/check-brew-cask-updates.sh"
    return $?
  else
    command brew "$@"
  fi
}
