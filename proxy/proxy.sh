#!/bin/bash

function __test_proxy() {
  local server_host="$1"
  local server_port="$2"
  local silent="$3"
  local server="http://$server_host:$server_port"

  curl -x $server -kfsI "https://google.com" >/dev/null 2>&1
  local code=$?

  if [[ -z "$silent" ]]; then
    if [[ $code -eq 0 ]]; then
      echo -e "\033[38;5;34mProxy server connection success.\033[0m"
    else
      echo -e "\033[38;5;124mProxy server connection failed.\033[0m"
    fi
  fi

  return $code
}

function __set_proxy() {
  local server_host="$1"
  local server_port="$2"
  local silent="$3"
  local force="$4"

  if [[ -z "$force" ]]; then
    proxy test --silent

    if [[ $? -ne 0 ]]; then
      if [[ -z "$silent" ]]; then
        echo -e "\033[38;5;124mProxy server setup failed.\033[0m"
      fi

      return 1
    fi
  fi

  export https_proxy="http://$server_host:$server_port"
  export http_proxy="http://$server_host:$server_port"
  export all_proxy="socks5://$server_host:$server_port"
}

function __unset_proxy() {
  unset https_proxy
  unset http_proxy
  unset all_proxy
}

function __info_proxy() {
  echo
  echo -e "\033[38;5;49mcurrent proxy server info:\033[0m"
  echo
  echo -e "  https_proxy \033[38;5;242m=> \033[38;5;44m$https_proxy\033[0m"
  echo -e "  http_proxy \033[38;5;242m=> \033[38;5;44m$http_proxy\033[0m"
  echo -e "  all_proxy \033[38;5;242m=> \033[38;5;44m$all_proxy\033[0m"
  echo
}

function __usage() {
  echo
  echo "usage: proxy test|set|unset|info"
  echo
  echo "  test   test proxy server"
  echo "  set    setup proxy server"
  echo "  unset  restore proxy server"
  echo "  info   proxy server information"
  echo
}

function proxy_server() {
  local server_port="7890"
  local server_host="127.0.0.1"

  if [[ "$OSTYPE" == "linux-gnu" && -n $(command -v wslsys) ]]; then
    local vsersion=$(wslsys -V | sed -e 's/[ :a-zA-Z]\+\(.*\)/\1/')

    if [[ $vsersion -eq 2 ]]; then
      server_host=$(cat "/etc/resolv.conf" | grep nameserver | awk '{print $2}')
    fi
  fi

  echo "$server_host:$server_port"
}

function proxy() {
  local server=$(proxy_server)
  local server_host=$(echo "$server" | awk -F: '{print $1}')
  local server_port=$(echo "$server" | awk -F: '{print $2}')

  case "$@" in
    "test" )
      __test_proxy "$server_host" "$server_port"
      ;;
    "test --silent" )
      __test_proxy "$server_host" "$server_port" "silent"
      ;;
    "set" )
      __set_proxy "$server_host" "$server_port"
      ;;
    "set --silent" )
      __set_proxy "$server_host" "$server_port" "silent"
      ;;
    "set --force" )
      __set_proxy "$server_host" "$server_port" "silent" "force"
      ;;
    "unset" )
      __unset_proxy
      ;;
    "info" )
      __info_proxy
      ;;
    * )
      __usage
      return 0
      ;;
  esac
}
