#!/bin/bash

_DIR_=$(cd "$(dirname "$0")" && pwd)
SSID_NAMES_FILE="${_DIR_}/names.txt"

function isLinux() {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "os: linux"
  fi
}

function trim() {
  local str="$1"

  if [[ $# -eq 0 ]]; then
    str=$(cat < /dev/stdin)
  fi

  echo "$str" | sed -e 's/^\s//' -e 's/\s$//'
}

function getConnectedWiFiSSID() {
  local WiFiSSID

  if [[ -z "$(isLinux)" ]]; then
    # wait
    WiFiSSID="macOS"
  else
    # Ubuntu (WSL1)
    WiFiSSID=$(powershell.exe -Command \(Get-NetConnectionProfile -InterfaceAlias 'WLAN' -ErrorAction Ignore\).Name)
  fi

  WiFiSSID=$(trim "$WiFiSSID")

  echo "$WiFiSSID"
}

function disableProxy() {
  if [[ ! -f "$SSID_NAMES_FILE" ]]; then
    return 1
  fi

  local WiFiSSID=$(getConnectedWiFiSSID)

  if [[ -z "$WiFiSSID" ]]; then
    return 0
  fi

  local line
  local names=()
  while IFS='' read -r line || [[ -n "$line" ]]; do
    line=$(echo "$line" | sed -e 's/#.*//')
    line=$(echo "$line" | trim)

    if [[ -z "$line" ]]; then
      continue
    fi

    names+=("$line")
  done < "$SSID_NAMES_FILE"

  local name
  local disabled
  for name in "${names[@]}"; do
    if [[ "$name" == "$WiFiSSID" ]]; then
      disabled="true"
      break
    fi
  done

  if [[ -z "$disabled" ]]; then
    return 0
  fi

  echo "$WiFiSSID"
}
