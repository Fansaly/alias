#!/bin/bash

ALIAS_DIR=$(cd "$(dirname "$0")" && pwd)

alias ass2lrc="${ALIAS_DIR}/ass2lrc/ass2lrc.sh"
alias shadow="${ALIAS_DIR}/shadow-image/shadow.sh"

source "${ALIAS_DIR}/upload-server/upload-server.sh"
source "${ALIAS_DIR}/localip/alias.sh"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias pbcopy="${ALIAS_DIR}/pasteboard/pbcopy.sh"
  alias pbpaste="${ALIAS_DIR}/pasteboard/pbpaste.sh"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  source "${ALIAS_DIR}/brew/alias.sh"
fi