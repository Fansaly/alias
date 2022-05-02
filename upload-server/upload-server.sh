#!/bin/bash

function __print-msg() {
  local  port="$1"
  local cname="$2"
  local token="$3"
  local ips=($(localip))
  local ip

  echo
  echo -e "\033[38;5;128m$cname\033[0m running at:"
  echo
  echo -e " - Local:   \033[0;36mhttp://localhost:\033[1;96m${port}\033[0m"

  if [[ ${#ips[@]} -gt 0 ]]; then
    for ip in "${ips[@]}"; do
      echo -e " - Network: \033[0;36mhttp://${ip}:\033[1;96m${port}\033[0m"
    done
  fi

  echo
  echo -e " token: \033[0;37m$token\033[0m"
  echo
}

function __exists-container__file-server() {
  local cname="$1"
  local res

  docker container ps -a --filter name=^${cname}$ | grep $cname

  if [[ $? -eq 0 ]]; then
    res="exists container: $cname"
  fi

  echo "$res"
}

function __delete-container__file-server() {
  local cname="$1"

  local exists=$(__exists-container__file-server "$cname")

  if [[ -n "$exists" ]]; then
    docker container rm -f "$cname"
  fi
}

function __create-container__file-server() {
  local iname="$1"
  local cname="$2"
  local  port="$3"
  local vpath="$4"
  local token="$5"

  mkdir -p "$vpath"

  docker container run \
    --name "$cname" \
    -p "$port":25478 \
    -v "$vpath":/var/root \
    -d "$iname" \
    -token "$token" \
    /var/root

  __print-msg "$port" "$cname" "$token"
}

function __start-container__file-server() {
  local cname="$1"
  local token="$2"

  local exists=$(__exists-container__file-server "$cname")

  if [[ -z "$exists" ]]; then
    echo -e "doesn't exists container: $cname"
    return 0
  fi

  docker container start "$cname"

  if [[ $? -eq 0 ]]; then
    __print-msg "$port" "$cname" "$token"
  fi
}

function __stop-container__file-server() {
  local cname="$1"

  docker container stop "$cname"
  echo -e "container stoped: $cname"
}

function __usage() {
  echo "file-server create|delete|start|stop"
  echo
  echo "  create  create file upload server docker container"
  echo "  delete  delete the container"
  echo "  start   start the container"
  echo "  stop    stop the container"
  echo
}

function file-server() {
  if [[ ! "$@" =~ ^(create|delete|start|stop)$ ]]; then
    # command file-server "$@"
    __usage
    return
  fi

  docker ps >/dev/null 2>&1
  local code=$?
  if [[ $code -ne 0 ]]; then
    echo -e '\033[38;5;88mdocker is not running.\033[0m'
    return $code
  fi

  local iname="mayth/simple-upload-server"
  local cname="file-upload-server"
  local  port="25478"
  local vpath="$HOME/tmp"
  local token="f9403fc5f537b4ab332d"

  case "$@" in
    "create" )
      __create-container__file-server \
        "$iname" "$cname" "$port" "$vpath" "$token"
      ;;
    "delete" )
      __delete-container__file-server \
        "$cname"
      ;;
    "start" )
      __start-container__file-server \
        "$cname" "$token"
      ;;
    "stop" )
      __stop-container__file-server \
        "$cname"
      ;;
    * )
      return 0
      ;;
  esac
}
