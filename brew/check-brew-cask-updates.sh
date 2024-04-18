#!/bin/bash

function padding() {
  local len=$1
  local char="$2"

  if [[ -z "$char" ]]; then
    char=" "
  fi

  local pad
  pad=$(printf '%*s' "$len")
  pad=${pad// /${char}}

  echo "$(printf '%*.*s' 0 $len "$pad")"
}

function substr() {
  local len=$1
  local str=${@:2}

  if [[ ${#str} -gt $len ]]; then
    str="${str:0:$len-4}\\033[0;36m..\\033[0m${str:${#str}-2}"
  fi

  echo -e "$str"
}

function printInfo() {
  local format="$1"
  local name="$2"
  local latest="$3"
  local current="$4"

  # ✓✔✗
  local char=✓

  if [[ "$latest" != "$current" ]]; then
    name="$name $char"
  fi

  local lens
  lens=($(echo "$format" | perl -pe 's/[^\s0-9]//g'))

  if [[ -z "${lens[0]}" ]]; then
    lens=("${lens[@]:1}")
  fi

  latest=$(substr ${lens[1]} "$latest")
  current=$(substr ${lens[2]} "$current")

  local s
  s="$(printf "$format" "$name" "$latest" "$current")"
  s=$(echo "$s" | sed -e 's/'"$char"'/\\033[0;92m'"$char"'\\033[0m/')

  echo -en "\r${s}\n"
}

function getAppsInfo() {
  local len=$1
  local apps=(${@:2})

  # ✓ and prev space
  local len_char=2
  local spaces_nv=$((5 - $len_char))
  local spaces_vv=5

  local len_name=$(($len + $len_char))
  local len_latest=18
  local len_current=18

  # `Application' length in title
  local len_name_min=$((11 + 5 + $spaces_nv))
  if [[ $len_name -lt $len_name_min ]]; then
    len_name=$len_name_min
  fi

  local pad_nv="$(padding $spaces_nv)"
  local pad_vv="$(padding $spaces_vv)"
  local format="%-${len_name}s${pad_nv}%-${len_latest}s${pad_vv}%-${len_current}s"

  len=$(($spaces_nv + $spaces_vv + $len_name + $len_latest + $len_current))
  local line="$(padding $len "-")"

  echo -e "$(printf "$format" "Application" "Latest" "Current")"
  echo -e "\033[0;37m${line}\033[0m"

  local app info latest current
  for app in ${apps[@]}; do
    echo -en "\033[0;37m${app} ... \033[0m"

    info=$(brew info --cask $app)

    if [[ ! $? -eq 0 ]]; then
      echo -e "\r\033[0;94m➤\033[0m ${app} \033[0;91m✗\033[0m \033[0;37mFailed to get info.\033[0m\n"
      continue
    fi

    latest=$( \
      echo "$info" | \
      sed -n 1p | \
      sed -e 's/.*'"$app"':[[:space:]]//' -e 's/[[:space:]](.*)//' \
    )
    current=$(echo "$info" | \
      sed -n 3p | \
      sed -e 's/.*\///' -e 's/[[:space:]](.*)//' \
    )

    printInfo "$format" "$app" "$latest" "$current"
  done
}

function getAppNameMaxLength() {
  local len=0
  local app

  for app in $@; do
    if [[ $len -lt ${#app} ]]; then
      len=${#app}
    fi
  done

  echo $len
}


apps=($(brew list --cask))
code=$?

if [[ ! $code -eq 0 ]]; then
  return $code &>/dev/null || exit $code
elif [[ ${#apps[@]} -eq 0 ]]; then
  echo "No application installed."
  return 0 &>/dev/null || exit 0
else
  len=$(getAppNameMaxLength "${apps[@]}")
  getAppsInfo $len "${apps[@]}"
fi
